import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:devjam_tw2025/auth.dart';
import 'package:devjam_tw2025/pages/login_page.dart';

class CustomDrawer extends StatelessWidget {
  final Function(int, String) onItemTapped;
  final int selectedIndex;
  final AuthModel authModel;
  final VoidCallback onLogout;

  const CustomDrawer({
    super.key,
    required this.onItemTapped,
    required this.selectedIndex,
    required this.authModel,
    required this.onLogout,
  });

  Widget _buildDrawerItem(BuildContext context, {required int index, required IconData icon, required String title, required String route}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      selected: selectedIndex == index,
      onTap: () {
        onItemTapped(index, route);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blueGrey),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '導航菜單',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
                SizedBox(height: 8),
                Text(
                  authModel.user?.email ?? '未登入',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
          ),
          _buildDrawerItem(context, index: 0, icon: Icons.home, title: '首頁', route: '/home'),
          _buildDrawerItem(context, index: 1, icon: Icons.show_chart, title: '暴露趨勢圖', route: '/exposure_trend'),
          _buildDrawerItem(context, index: 2, icon: Icons.restaurant, title: '食物紀錄', route: '/food_record'),
          _buildDrawerItem(context, index: 3, icon: Icons.directions_car, title: '交通紀錄', route: '/traffic_record'),
          _buildDrawerItem(context, index: 4, icon: Icons.fitness_center, title: '健身紀錄', route: '/fitness_record'),
          _buildDrawerItem(context, index: 5, icon: Icons.pie_chart, title: '汙染分布圖', route: '/pollution_distribution'),
          _buildDrawerItem(context, index: 6, icon: Icons.lightbulb, title: '行為建議', route: '/behavior_suggestion'),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('登出'),
            onTap: onLogout,
          ),
        ],
      ),
    );
  }
}