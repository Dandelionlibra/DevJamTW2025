import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SilverGo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return const HomeScreen();
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('今日汙染暴露'), backgroundColor: Colors.grey),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const Text(
              '今日汙染暴露',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            CircularProgressIndicator(
              value: 324 / 1000,
              strokeWidth: 10,
              backgroundColor: Colors.grey,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
            ),
            const SizedBox(height: 10),
            const Text(
              '324 μg / 1000 μg',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text('食物 180 μg  交通 96 μg  健身 48 μg'),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.restaurant),
                      title: const Text('食物'),
                      subtitle: const Text('晚餐：炸雞、午餐：泡麵\n今日攝取：180 μg'),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.directions_car),
                      title: const Text('交通'),
                      subtitle: const Text('通勤時間：45 分鐘\n預估暴露：96 μg'),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.fitness_center),
                      title: const Text('健身'),
                      subtitle: const Text('運動：慢跑 30 分鐘\n呼吸暴露量：48 μg'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
