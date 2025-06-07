CREATE TABLE paper_types (
    id SERIAL PRIMARY KEY,
    type_name TEXT NOT NULL UNIQUE,                     -- 紙類名稱（如：PE淋膜紙、純紙、PLA淋膜紙等）
    -- description TEXT,                                   -- 紙類簡介或製程說明
    -- typical_uses TEXT,                                  -- 常見用途（如早餐店紙杯、便當盒）
    pollutant_release_cold_mg NUMERIC DEFAULT NULL,     -- 常溫水下釋放總量（mg / 100mL）
    pollutant_release_hot_mg NUMERIC DEFAULT NULL       -- 高溫水下釋放總量（mg / 100mL）
);
INSERT INTO paper_types ( type_name, pollutant_release_cold_mg, pollutant_release_hot_mg) VALUES
('紙杯', 0, 88750),
('紙碗', 20, 92000),
('紙餐盒', 0, 80000);

CREATE TABLE plastic_types (
    code INT PRIMARY KEY CHECK (code BETWEEN 1 AND 7),  -- 編號 1~7
    abbreviation TEXT NOT NULL UNIQUE,                 -- 如 PET、PP
    -- full_name TEXT NOT NULL,                           -- 英文全名
    -- chinese_name TEXT NOT NULL,                        -- 中文名稱
    -- typical_uses TEXT,                                 -- 常見用途
	pollutant_release_cold_mg NUMERIC DEFAULT NULL,    -- 常溫水下釋放總量（mg / 100mL）
    pollutant_release_hot_mg NUMERIC DEFAULT NULL      -- 高溫水下釋放總量（mg / 100mL）
);

INSERT INTO plastic_types ( code, abbreviation, pollutant_release_cold_mg, pollutant_release_hot_mg) VALUES
(1, 'PET', 0, 80000),
(2, 'HDPE', 0, NULL),
(3, 'PVC', NULL, NULL),
(4, 'LDPE', 20, 79500),
(5, 'PP', 20, 4250),
(6, 'PS', NULL, 170000),
(7, 'OTHER', NULL, NULL);
select * from plastic_types;


CREATE TABLE containers (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,                         -- 容器名稱，如「塑膠杯」、「塑膠碗」
    material TEXT NOT NULL CHECK (                     -- 材質
        material IN ('紙', '塑膠', '其他')
    ),
	paper_name TEXT REFERENCES paper_types(type_name);        -- 紙類專用
	plastic_abbr TEXT REFERENCES plastic_types(abbreviation), -- 塑膠專用
);




CREATE OR REPLACE FUNCTION validate_container_material_links()
RETURNS TRIGGER AS $$
BEGIN
    -- 當材質為「塑膠」時
    IF NEW.material = '塑膠' THEN
        IF NEW.plastic_abbr IS NULL THEN
            RAISE EXCEPTION '塑膠容器必須指定 plastic_abbr';
        ELSIF NEW.paper_name IS NOT NULL THEN
            RAISE EXCEPTION '塑膠容器不應指定 paper_name';
        END IF;

    -- 當材質為「紙」時
    ELSIF NEW.material = '紙' THEN
        IF NEW.paper_name IS NULL THEN
            RAISE EXCEPTION '紙容器必須指定 paper_name';
        ELSIF NEW.plastic_abbr IS NOT NULL THEN
            RAISE EXCEPTION '紙容器不應指定 plastic_abbr';
        END IF;

    -- 當材質為「其他」時
    ELSIF NEW.material = '其他' THEN
        IF NEW.plastic_abbr IS NOT NULL OR NEW.paper_name IS NOT NULL THEN
            RAISE EXCEPTION '非塑膠／紙容器不應指定 plastic_abbr 或 paper_name';
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validate_container_material_links
BEFORE INSERT OR UPDATE ON containers
FOR EACH ROW
EXECUTE FUNCTION validate_container_material_links();

