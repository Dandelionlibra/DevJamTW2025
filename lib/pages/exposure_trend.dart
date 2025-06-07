import 'package:flutter/material.dart';

class ExposureTrendScreen extends StatelessWidget {
  const ExposureTrendScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: const Center(
        child: Text(
          '暴露趨勢圖 - 這裡可以顯示折線圖或趨勢數據',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}