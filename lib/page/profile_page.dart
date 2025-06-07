import 'package:flutter/material.dart';
import 'all_page.dart'; // 匯入所有頁面
import 'package:provider/provider.dart';
import 'package:Wandering/auth.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    String uid =
        Provider.of<AuthModel>(context, listen: false).user?.uid ?? 'unknown';
    String username = Provider.of<AuthModel>(
      context,
      listen: false,
    ).getUserName();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '個人資訊',
          style: TextStyle(
            fontSize: GetFontSize(),
            color: const Color.fromARGB(255, 255, 255, 255),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent, // 設置 AppBar 背景透明
        elevation: 0, // 去掉 AppBar 陰影
        iconTheme: IconThemeData(
          color: const Color.fromARGB(255, 255, 255, 255),
        ), // 設置返回按鈕顏色
      ),
      extendBodyBehindAppBar: true, // 讓 Body 內容延伸到 AppBar 後面
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: getCardGradientColors(),
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView(
          // 使用 ListView 使內容可滾動
          children: <Widget>[
            SizedBox(height: 20), // 留出 AppBar 的空間
            // 頭像、名稱和 ID
            Column(
              children: [
                CircleAvatar(
                  // 圓形頭像
                  radius: 50,
                  backgroundImage: AssetImage(
                    'assets/images/avatar.png',
                  ), // 頭像圖片路徑
                ),
                SizedBox(height: 10),
                Text(
                  username, // 用戶名稱
                  style: TextStyle(
                    fontSize: GetFontSize() + 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'ID: $uid', // 用戶 ID
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ],
            ),
            SizedBox(height: 30),
            // 三個功能按鈕
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround, // 平均分佈按鈕
                children: <Widget>[
                  buildFeatureButton(Icons.assignment, '行程記錄'),
                  buildFeatureButton(Icons.bookmark, '我的收藏'),
                  buildFeatureButton(Icons.monitor_heart, '偏好設定'),
                ],
              ),
            ),
            SizedBox(height: 30),
            // 列表項
            Card(
              // 將列表項放在 Card 中
              margin: EdgeInsets.symmetric(horizontal: 20.0),
              elevation: 5, // 添加陰影
              shape: RoundedRectangleBorder(
                // 設置圓角
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                // 使用 Column 垂直排列列表項
                children: <Widget>[
                  buildProfileListItem(Icons.person_outline, '我的資料'),
                  Divider(indent: 20, endIndent: 20), // 分隔線
                  buildProfileListItem(Icons.explore_outlined, '我的探索記錄'),
                  Divider(indent: 20, endIndent: 20),
                  buildProfileListItem(Icons.chat_bubble_outline, '評論與心得'),
                  Divider(indent: 20, endIndent: 20),
                  buildProfileListItem(Icons.share, '分享 App'),
                  Divider(indent: 20, endIndent: 20),
                  buildProfileListItem(Icons.phone, '聯絡我們'),
                  Divider(indent: 20, endIndent: 20),
                  buildProfileListItem(Icons.settings_outlined, '設定'),
                ],
              ),
            ),
            SizedBox(height: 20), // 底部留白
          ],
        ),
      ),
    );
  }

  // 構建功能按鈕的函數
  Widget buildFeatureButton(IconData icon, String label) {
    return ElevatedButton(
      onPressed: () {
        // 處理按鈕點擊事件
        print('$label 點擊');
        if (label == '行程紀錄') {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (context) => SettingsPage()),
          // );
        } else if (label == '我的收藏') {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (context) => SettingsPage()),
          // );
        } else if (label == '偏好設定') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PreferenceSummaryPage()),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black87,
        backgroundColor: Colors.white, // 按鈕文字和圖標顏色，以及背景顏色
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // 設置圓角
        ),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15), // 內邊距
        // textStyle: TextStyle(fontSize: GetFontSize()), // 設定字體大小
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon, size: 30), SizedBox(height: 5), Text(label)],
      ),
    );
  }

  // 構建列表項的函數
  Widget buildProfileListItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.black54), // 圖標
      title: Text(title, style: TextStyle(fontSize: GetFontSize())), // 文字
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: GetFontSize() + 4,
        color: Colors.black54,
      ), // 箭頭
      onTap: () {
        // 處理列表項點擊事件
        print('$title 點擊');
        if (title == '我的資料') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => UserInfoPage()),
          );
        } else if (title == '我的收藏') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SettingsPage()),
          );
        } else if (title == '我的探索記錄') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MyExploreLogPage()),
          );
        } else if (title == '評論與心得') {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (context) => FeedbackStatsPage(averageRating: null,, wordFrequencies: {},)),
          // );
        } else if (title == '分享 App') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => InfoSharePage()),
          );
        } else if (title == '聯絡我們') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ContactPage()),
          );
        } else if (title == '設定') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SettingsPage()),
          );
        }
      },
    );
  }
}
