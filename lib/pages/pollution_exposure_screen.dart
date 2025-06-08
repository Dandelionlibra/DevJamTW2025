import 'package:flutter/material.dart';
import 'package:devjam_tw2025/data/today_data.dart';

class PollutionExposureScreen extends StatelessWidget {
  final List<ExposureRecord> records;
  final Function(ExposureRecord) onDelete;
  final Function(ExposureRecord) onEdit;

  const PollutionExposureScreen({
    Key? key,
    required this.records,
    required this.onDelete,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('污染暴露紀錄'),
      ),
      body: records.isEmpty
          ? const Center(child: Text('目前沒有污染暴露紀錄'))
          : ListView.builder(
              itemCount: records.length,
              itemBuilder: (context, index) {
                final record = records[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('事件類型: ${record.eventType}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        if (record.note != null) Text('備註: ${record.note}'),
                        if (record.transportMode != null) Text('交通方式: ${record.transportMode}'),
                        Text('開始時間: ${record.startTime}'),
                        if (record.endTime != null) Text('結束時間: ${record.endTime}'),
                        if (record.exerciseLocation != null) Text('運動地點: ${record.exerciseLocation}'),
                        if (record.intensity != null) Text('強度: ${record.intensity}'),
                        if (record.durationMinutes != null) Text('持續時間: ${record.durationMinutes} 分鐘'),
                        if (record.photoUrl != null) Image.network(record.photoUrl!),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => onEdit(record),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => onDelete(record),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
import 'package:devjam_tw2025/data/today_data.dart';