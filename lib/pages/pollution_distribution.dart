import 'package:flutter/material.dart';

class PollutionDistributionScreen extends StatelessWidget {
  const PollutionDistributionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          '汙染分布圖 - 這裡可以顯示圓環圖或圓形圖表',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}