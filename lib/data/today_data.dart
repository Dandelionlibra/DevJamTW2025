import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

class ExposureRecord {
  final String? uid;
  final String eventType;
  final String? note;
  final String? transportMode;
  final String startTime;
  final String? endTime;
  final String? exerciseLocation;
  final String? intensity;
  final int? durationMinutes;
  final String? imagePath;
  final String? photoUrl;

  ExposureRecord({
    this.uid,
    required this.eventType,
    this.note,
    this.transportMode,
    required this.startTime,
    this.endTime,
    this.exerciseLocation,
    this.intensity,
    this.durationMinutes,
    this.imagePath,
    this.photoUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'event_type': eventType,
      'note': note,
      'transport_mode': transportMode,
      'start_time': startTime,
      'end_time': endTime,
      'exercise_location': exerciseLocation,
      'intensity': intensity,
      'duration_minutes': durationMinutes,
      'image_path': imagePath,
      'photo_url': photoUrl,
    };
  }

  factory ExposureRecord.fromJson(Map<String, dynamic> json) {
    return ExposureRecord(
      uid: json['uid'],
      eventType: json['event_type'],
      note: json['note'],
      transportMode: json['transport_mode'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      exerciseLocation: json['exercise_location'],
      intensity: json['intensity'],
      durationMinutes: json['duration_minutes'],
      imagePath: json['image_path'],
      photoUrl: json['photo_url'],
    );
  }

  static Future<ExposureRecord> addRecord(ExposureRecord record) async {
    final supabase = Supabase.instance.client;
    if (record.uid == null) throw Exception('User not authenticated');

    if (record.imagePath != null && record.eventType == '食物') {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${record.imagePath!.split('/').last}';
      final filePath = '/${record.uid}/$fileName';
      try {
        await supabase.storage
            .from('user-photo')
            .uploadBinary(
              filePath,
              await File(record.imagePath!).readAsBytes(),
              fileOptions: const FileOptions(contentType: 'image/jpeg'),
            );
        final photoUrl = 'https://your-supabase-url.supabase.co/storage/v1/object/public/user-photo/${record.uid}/$fileName'; // 替換為您的 URL
        record = record.copyWith(photoUrl: photoUrl);
      } catch (e) {
        print('Upload failed: $e');
        throw Exception('Upload failed: $e');
      }
    }

    // 將記錄保存到 Supabase 數據庫
    final response = await supabase
        .from('exposure_records') // 確保表名正確
        .insert(record.toJson())
        .select()
        .single();
    return ExposureRecord.fromJson(response);
  }

  ExposureRecord copyWith({
    String? uid,
    String? eventType,
    String? note,
    String? transportMode,
    String? startTime,
    String? endTime,
    String? exerciseLocation,
    String? intensity,
    int? durationMinutes,
    String? imagePath,
    String? photoUrl,
  }) {
    return ExposureRecord(
      uid: uid ?? this.uid,
      eventType: eventType ?? this.eventType,
      note: note ?? this.note,
      transportMode: transportMode ?? this.transportMode,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      exerciseLocation: exerciseLocation ?? this.exerciseLocation,
      intensity: intensity ?? this.intensity,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      imagePath: imagePath ?? this.imagePath,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}