
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('登入頁面')),
      body: const Center(child: Text('這是登入頁面示例', style: TextStyle(fontSize: 24))),
    );
  }
}