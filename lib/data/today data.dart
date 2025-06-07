import 'package:http/http.dart' as http;
import 'dart:convert';

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
  final String? imagePath; // Added back imagePath

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
    this.imagePath, // Added back
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
      'image_path': imagePath, // Added to JSON
    };
  }

  static Future<void> addRecord(ExposureRecord record) async {
    const url = 'https://n8n.ja-errorpro.codes/webhook/b04f3c8e-6a65-4d75-a573-4820e3c35a5b';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(record.toJson()),
      );
      if (response.statusCode == 200) {
        print('Record added successfully');
      } else {
        print('Failed to add record: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to add record');
      }
    } catch (e) {
      print('Error adding record: $e');
      throw Exception('Error adding record: $e');
    }
  }
}