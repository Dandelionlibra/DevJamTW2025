CREATE TABLE activity_records (
    record_id TEXT PRIMARY KEY,                         -- 前端生成的唯一識別碼
    user_id TEXT NOT NULL REFERENCES user_profile_data(user_id),

    event_type TEXT NOT NULL CHECK (
        event_type IN ('transport', 'exercise', 'diet', 'breath')
    ),                                                  -- 行為類型

    photoUrl TEXT,                               
    note TEXT,                                          -- 自由備註
	
    pm25_exposure DOUBLE PRECISION DEFAULT NULL,        -- 該活動期間暴露之 PM2.5 總量 (μg)
    transport_mode TEXT CHECK (
        transport_mode IN ('機車', '汽車', '大眾交通工具')
    ),                                                  -- 交通方式（若 event_type = transport）
    start_time TIMESTAMP,
    end_time TIMESTAMP,

    exercise_location TEXT CHECK (
        exercise_location IN ('indoor', 'outdoor')
    ),                                                  -- 室內/室外（若 event_type = exercise）

    intensity TEXT CHECK (
        intensity IN ('high', 'low')
    ),                                                  -- 強度（若 event_type = exercise）
    duration_minutes INT CHECK (duration_minutes >= 0), -- 行為持續時間（分鐘）
	

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 當 event_type = 'transport' → 必須填 transport_mode
-- 當 event_type = 'exercise' → 必須填 exercise_location 和 intensity
-- 當 event_type = 'diet' → 必須填 note 與 photoUrl
CREATE OR REPLACE FUNCTION validate_activity_record_fields()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.event_type = 'transport' THEN
        IF NEW.transport_mode IS NULL THEN
            RAISE EXCEPTION 'transport_mode 必須在 event_type = transport 時提供';
        ELSIF NEW.pm25_exposure IS NULL THEN
            RAISE EXCEPTION 'pm25_exposure 必須在 event_type = transport 時提供';
			
		END IF;

    ELSIF NEW.event_type = 'exercise' THEN
        IF NEW.exercise_location IS NULL THEN
            RAISE EXCEPTION 'exercise_location 必須在 exercise 時提供';
        ELSIF NEW.intensity IS NULL THEN
            RAISE EXCEPTION 'intensity 必須在 exercise 時提供';
        ELSIF NEW.pm25_exposure IS NULL THEN
            RAISE EXCEPTION 'pm25_exposure 必須在 exercise 時提供';
        END IF;

    ELSIF NEW.event_type = 'diet' THEN
        IF NEW.note IS NULL THEN
            RAISE EXCEPTION 'note 必須在 diet 時提供';
        ELSIF NEW.photoUrl IS NULL THEN
            RAISE EXCEPTION 'photoUrl 必須在 diet 時提供';
        END IF;

    ELSIF NEW.event_type = 'breath' THEN
        IF NEW.exercise_location IS NULL THEN
            RAISE EXCEPTION 'exercise_location 必須在 breath 時提供';
        ELSIF NEW.pm25_exposure IS NULL THEN
            RAISE EXCEPTION 'pm25_exposure 必須在 breath 時提供';
        END IF;
    ELSE
        RAISE EXCEPTION '不支援的 event_type：%（允許值為 transport, exercise, diet, breath）', NEW.event_type;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validate_activity_fields
BEFORE INSERT OR UPDATE ON activity_records
FOR EACH ROW
EXECUTE FUNCTION validate_activity_record_fields();






CREATE OR REPLACE FUNCTION log_diet_pollution(new_rec activity_records)
RETURNS VOID AS $$
DECLARE
    food_name TEXT;
    exposure RECORD;
BEGIN
    -- 假設 note 是單一食品名稱，可依需求強化為 parser
    food_name := TRIM(new_rec.note);

    FOR exposure IN
        SELECT pollutant_id, average_level, unit_id
        FROM food_items
        WHERE name = food_name
    LOOP
        INSERT INTO user_exposure_logs (
            user_id, exposure_time, pollutant_id, amount, unit_id
        ) VALUES (
            new_rec.user_id,
            new_rec.start_time,
            exposure.pollutant_id,
            exposure.average_level,
            exposure.unit_id
        );
    END LOOP;
END;
$$ LANGUAGE plpgsql;





CREATE OR REPLACE FUNCTION process_activity_insert()
RETURNS TRIGGER AS $$
DECLARE
    duration_minutes INT;
    exposure_pm25 DOUBLE PRECISION;
    ef_transport DOUBLE PRECISION;
    ef_exercise DOUBLE PRECISION;
    intensity_factor DOUBLE PRECISION;
    exercise_pm25 DOUBLE PRECISION := 30; -- 預設戶外濃度，可日後改為氣象API導入
BEGIN
    -- 依據不同 event_type 執行對應邏輯
    IF NEW.event_type = 'diet' THEN
        -- 呼叫 log_diet_pollution 估算飲食污染
        PERFORM log_diet_pollution(NEW);

    ELSIF NEW.event_type = 'transport' THEN
        -- 計算交通所暴露的 PM2.5
        duration_minutes := EXTRACT(EPOCH FROM (NEW.end_time - NEW.start_time)) / 60;

        CASE NEW.transport_mode
            WHEN '機車' THEN ef_transport := 32.1;
            WHEN '汽車' THEN ef_transport := 7.6;
            WHEN '大眾交通工具' THEN ef_transport := 22.7;
            ELSE ef_transport := 0;
        END CASE;

        exposure_pm25 := ef_transport * duration_minutes;

        -- 寫入 user_exposure_logs
        INSERT INTO user_exposure_logs (
            user_id, pollutant_id, exposure_source, exposure_amount, recorded_at
        )
        VALUES (
            NEW.user_id,
            999, -- 999 = PM2.5 的 pollutant_id（預設，你可改為實際 id）
            CONCAT('transport:', NEW.transport_mode),
            exposure_pm25,
            NEW.start_time
        );

    ELSIF NEW.event_type = 'exercise' THEN
        -- 運動暴露估算
        duration_minutes := EXTRACT(EPOCH FROM (NEW.end_time - NEW.start_time)) / 60;

        -- 地點對應 EF（μg/m³）
        IF NEW.exercise_location = 'indoor' THEN
            ef_exercise := 10;
        ELSIF NEW.exercise_location = 'outdoor' THEN
            ef_exercise := exercise_pm25;
        ELSE
            ef_exercise := 10; -- fallback
        END IF;

        -- 強度對應係數
        CASE NEW.intensity
            WHEN 'high' THEN intensity_factor := 2.5;
            WHEN 'low' THEN intensity_factor := 1;
            ELSE intensity_factor := 1;
        END CASE;

        exposure_pm25 := ef_exercise * duration_minutes * intensity_factor;

        -- 寫入 user_exposure_logs
        INSERT INTO user_exposure_logs (
            user_id, pollutant_id, exposure_source, exposure_amount, recorded_at
        )
        VALUES (
            NEW.user_id,
            999, -- PM2.5
            CONCAT('exercise:', NEW.exercise_location, '/', NEW.intensity),
            exposure_pm25,
            NEW.start_time
        );

    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;





-- 測試 1：transport（必須有 transport_mode）
INSERT INTO activity_records (
    record_id, user_id, event_type, transport_mode,
    start_time, end_time, duration_minutes, created_at
) VALUES (
    'r001', '1', 'transport', '機車',
    NULL, '2025-06-08 08:30:00', 30, CURRENT_TIMESTAMP
);

-- 測試 2：exercise（必須有 exercise_location 和 intensity）
INSERT INTO activity_records (
    record_id, user_id, event_type, exercise_location, intensity,
    start_time, end_time, duration_minutes, created_at
) VALUES (
    'r002', '1', 'exercise', 'outdoor', 'high',
    '2025-06-08 18:00:00', '2025-06-08 18:45:00', 45, CURRENT_TIMESTAMP
);

-- 測試 3：diet（必須有 note 和 photoUrl）
INSERT INTO activity_records (
    record_id, user_id, event_type, note, photoUrl,
    start_time, end_time, duration_minutes, created_at
) VALUES (
    'r003', '1', 'diet',
    '早餐：飲用手搖飲與蛋餅',
    'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAA...fakebase64...',
    '2025-06-08 07:30:00', '2025-06-08 07:40:00', 10, CURRENT_TIMESTAMP
);





CREATE OR REPLACE FUNCTION calculate_transport_pm25()
RETURNS TRIGGER AS $$
DECLARE
    duration_minutes INT;
    ef DOUBLE PRECISION;
BEGIN
    -- 僅處理 event_type = 'transport'
    IF NEW.event_type = 'transport' THEN
        -- 若缺少必要欄位，直接返回錯誤
        IF NEW.transport_mode IS NULL THEN
            RAISE EXCEPTION 'transport_mode 不可為 NULL';
        END IF;

        -- 計算行為持續時間（分鐘）
        duration_minutes := EXTRACT(EPOCH FROM (NEW.end_time - NEW.start_time)) / 60;

        -- 對應各種交通工具的 PM2.5 暴露因子（μg/分鐘）
        CASE NEW.transport_mode
            WHEN '機車' THEN ef := 32.1;
            WHEN '汽車' THEN ef := 7.6;
            WHEN '大眾交通工具' THEN ef := 22.7;
            ELSE
                RAISE EXCEPTION '未知的 transport_mode: %', NEW.transport_mode;
        END CASE;

        -- 計算總暴露量
        NEW.duration_minutes := duration_minutes;
        NEW.pm25_exposure := ef * duration_minutes;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER trigger_transport_pm25
BEFORE INSERT ON activity_records
FOR EACH ROW
EXECUTE FUNCTION calculate_transport_pm25();

CREATE OR REPLACE FUNCTION calculate_exercise_pm25()
RETURNS TRIGGER AS $$
DECLARE
    duration_minutes INT;
    ef_exercise DOUBLE PRECISION;
    intensity_factor DOUBLE PRECISION;
    exercise_pm25 DOUBLE PRECISION := 30; -- 預設戶外濃度，可從外部天氣API帶入
BEGIN
    IF NEW.event_type = 'exercise' THEN
        -- 基本檢查
        IF NEW.exercise_location IS NULL OR NEW.intensity IS NULL THEN
            RAISE EXCEPTION '運動類型需指定 exercise_location 與 intensity';
        END IF;

        -- 運動時間
        duration_minutes := EXTRACT(EPOCH FROM (NEW.end_time - NEW.start_time)) / 60;
        NEW.duration_minutes := duration_minutes;

        -- 地點對應 EF（μg/m³）
        IF NEW.exercise_location = 'indoor' THEN
            ef_exercise := 10;
        ELSIF NEW.exercise_location = 'outdoor' THEN
            ef_exercise := exercise_pm25;
        ELSE
            ef_exercise := 10; -- fallback
        END IF;

        -- 強度對應係數
        CASE NEW.intensity
            WHEN 'high' THEN intensity_factor := 2.5;
            WHEN 'low' THEN intensity_factor := 1;
            ELSE
                intensity_factor := 1; -- fallback
        END CASE;

        -- 最終暴露計算
        NEW.pm25_exposure := ef_exercise * duration_minutes * intensity_factor;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER trigger_exercise_pm25
BEFORE INSERT ON activity_records
FOR EACH ROW
EXECUTE FUNCTION calculate_exercise_pm25();

