import 'package:flutter/material.dart';

class FitnessRecordScreen extends StatelessWidget {
  const FitnessRecordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: const Center(
        child: Text(
          '健身紀錄 - 這裡可以顯示運動數據',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}