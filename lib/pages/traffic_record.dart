import 'package:flutter/material.dart';

class TrafficRecordScreen extends StatelessWidget {
  const TrafficRecordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          '交通紀錄 - 這裡可以顯示通勤數據',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}