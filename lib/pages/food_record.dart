import 'package:flutter/material.dart';

class FoodRecordScreen extends StatelessWidget {
  const FoodRecordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      body: const Center(
        child: Text(
          '食物紀錄 - 這裡可以顯示食物攝取清單',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}