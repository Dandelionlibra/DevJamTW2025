// import 'package:flutter/material.dart';
// import 'page/login_page.dart'; // 導入 login_page.dart
//
// void main() {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Navigation Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blueGrey,
//         scaffoldBackgroundColor: Colors.grey[100],
//       ),
//       initialRoute: '/home',
//       routes: {
//         '/home': (context) => const HomeScreen(),
//         '/exposure_trend': (context) => const ExposureTrendScreen(),
//         '/food_record': (context) => const FoodRecordScreen(),
//         '/traffic_record': (context) => const TrafficRecordScreen(),
//         '/fitness_record': (context) => const FitnessRecordScreen(),
//         '/pollution_distribution': (context) => const PollutionDistributionScreen(),
//         '/login': (context) => const LoginPage(), // 跳轉到登入頁面
//       },
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }
//
// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});
//
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> {
//   int _selectedIndex = 0;
//
//   void _onDrawerItemTapped(int index, String route) {
//     setState(() {
//       _selectedIndex = index;
//     });
//     Navigator.pop(context); // 關閉抽屜
//     if (route != '/home') {
//       Navigator.pushNamed(context, route);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('首頁'),
//       ),
//       body: const Center(
//         child: Text('歡迎來到首頁', style: TextStyle(fontSize: 24)),
//       ),
//       drawer: CustomDrawer(
//         onItemTapped: _onDrawerItemTapped,
//         selectedIndex: _selectedIndex,
//       ),
//     );
//   }
// }
//
// class CustomDrawer extends StatelessWidget {
//   const CustomDrawer({
//     super.key,
//     required this.onItemTapped,
//     required this.selectedIndex,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Drawer(
//       child: ListView(
//         padding: EdgeInsets.zero,
//         children: [
//           const DrawerHeader(
//             decoration: BoxDecoration(color: Colors.blueGrey),
//             child: Text(
//               '導航菜單',
//               style: TextStyle(color: Colors.white, fontSize: 24),
//             ),
//           ),
//           _buildDrawerItem(context, index: 0, icon: Icons.home, title: '首頁', route: '/home'),
//           _buildDrawerItem(context, index: 1, icon: Icons.show_chart, title: '暴露趨勢圖', route: '/exposure_trend'),
//           _buildDrawerItem(context, index: 2, icon: Icons.restaurant, title: '食物紀錄', route: '/food_record'),
//           _buildDrawerItem(context, index: 3, icon: Icons.directions_car, title: '交通紀錄', route: '/traffic_record'),
//           _buildDrawerItem(context, index: 4, icon: Icons.fitness_center, title: '健身紀錄', route: '/fitness_record'),
//           _buildDrawerItem(context, index: 5, icon: Icons.pie_chart, title: '汙染分布圖', route: '/pollution_distribution'),
//           _buildDrawerItem(context, index: 6, icon: Icons.login, title: '行為建議', route: '/login'),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDrawerItem(BuildContext context, {required int index, required IconData icon, required String title, required String route}) {
//     return ListTile(
//       leading: Icon(icon),
//       title: Text(title, style: TextStyle(
//         color: selectedIndex == index ? Theme.of(context).primaryColor : null,
//         fontWeight: selectedIndex == index ? FontWeight.bold : FontWeight.normal,
//       )),
//       selected: selectedIndex == index,
//       onTap: () => onItemTapped(index, route),
//     );
//   }
// }
//
// class ExposureTrendScreen extends StatelessWidget {
//   const ExposureTrendScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('暴露趨勢圖')),
//       body: const Center(child: Text('這裡顯示暴露趨勢數據示例', style: TextStyle(fontSize: 24))),
//     );
//   }
// }
//
// class FoodRecordScreen extends StatelessWidget {
//   const FoodRecordScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('食物紀錄')),
//       body: const Center(child: Text('這裡顯示食物攝取清單示例', style: TextStyle(fontSize: 24))),
//     );
//   }
// }
//
// class TrafficRecordScreen extends StatelessWidget {
//   const TrafficRecordScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('交通紀錄')),
//       body: const Center(child: Text('這裡顯示通勤數據示例', style: TextStyle(fontSize: 24))),
//     );
//   }
// }
//
// class FitnessRecordScreen extends StatelessWidget {
//   const FitnessRecordScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('健身紀錄')),
//       body: const Center(child: Text('這裡顯示運動數據示例', style: TextStyle(fontSize: 24))),
//     );
//   }
// }
//
// class PollutionDistributionScreen extends StatelessWidget {
//   const PollutionDistributionScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('汙染分布圖')),
//       body: const Center(child: Text('這裡顯示汙染分布示例', style: TextStyle(fontSize: 24))),
//     );
//   }
// }