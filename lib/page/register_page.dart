import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:Wandering/auth.dart';
import 'all_page.dart'; // 匯入所有頁面

class Register extends StatefulWidget {
  // TODO: Add TextEditingControllers for input fields
  // TODO: Implement registration logic
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController userEmailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      // appBar: AppBar(
      //   title: const Text('註冊一個新帳號'),
      //   centerTitle: true,
      //   backgroundColor: Colors.transparent,
      //   elevation: 0,
      // ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                // const SizedBox(height: 40),
                // Logo 圖示
                Image.asset('assets/images/wandering_5.PNG', height: 200, width: 200),
                const SizedBox(height: 10),
                // const SizedBox(height: 30),
                const Text(
                  // 歡迎加入 Wandering\n
                  '給自己一個開始，\n也給風景一個機會遇見你。', textAlign: TextAlign.center, // 文字置中
                  style: TextStyle(
                    fontFamily: 'ChenYuluoyan', // 使用自定義字體
                    color: Color.fromARGB(255, 6, 48, 66),
                    fontSize: 20,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 32),

                // 使用者名稱欄位
                _grayBorderedField(
                  child: _roundedInputField(
                    controller: userNameController,
                    hint: '使用者名稱',
                    obscure: false,
                  ),
                ),

                const SizedBox(height: 16),

                // 電子郵箱欄位
                _grayBorderedField(
                  child: _roundedInputField(
                    controller: userEmailController,
                    hint: '電子郵箱',
                    obscure: false,
                  ),
                ),

                const SizedBox(height: 16),

                // 密碼欄位
                _grayBorderedField(
                  child: _roundedInputField(
                    controller: passwordController,
                    hint: '密碼',
                    obscure: true,
                  ),
                ),

                const SizedBox(height: 32),

                // 註冊按鈕（漸層）
                GestureDetector(
                  onTap: () {
                    Provider.of<AuthModel>(
                      context,
                      listen: false,
                    ).register(
                      context,
                      userNameController.text,
                      userEmailController.text,
                      passwordController.text,
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF7beec5),
                          Color(0xFF01e6fa),
                          Color(0xFF32c8ff),
                          Color(0xFFc0e8cb),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        '註冊',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // 返回登入頁
                  },
                  child: const Text(
                    '已經有帳號？返回登入',
                    style: TextStyle(color: Colors.cyanAccent),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 輸入欄外框
  Widget _grayBorderedField({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(32),
      ),
      child: child,
    );
  }

  /// 圓角白底欄位
  Widget _roundedInputField({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          border: InputBorder.none,
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.black26, fontSize: 16),
        ),
      ),
    );
  }
}



/*import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:Wandering/auth.dart';
import 'all_page.dart'; // 匯入所有頁面

class Register extends StatelessWidget {
  // TODO: Add TextEditingControllers for input fields
  // TODO: Implement registration logic

  @override
  Widget build(BuildContext context) {
    final TextEditingController userNameController = TextEditingController();
    final TextEditingController userEmailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('註冊一個新帳號'),
        centerTitle: true, // 新增這行來居中標題
      ),
      body: Padding(
        // 添加 Padding 使內容不貼邊
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              // autofocus: true, // 光標（在桌面設備上）會自動出現在該輸入框中。可能會影響使用者體驗，建議移除
              decoration: InputDecoration(
                labelText: "使用者名稱",
                hintText: "Yiji",
                prefixIcon: Icon(Icons.person),
              ),
              controller: userNameController,
              // TODO: Assign a TextEditingController
            ),
            const SizedBox(height: 12), // 增加 TextField 之間的間距
            TextField(
              // autofocus: true, // 光標（在桌面設備上）會自動出現在該輸入框中。
              decoration: InputDecoration(
                labelText: "電子郵箱",
                hintText: "Yiji@example.com",
                prefixIcon: Icon(Icons.mail),
              ),
              controller: userEmailController,
              // TODO: Assign a TextEditingController
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                labelText: "密碼",
                hintText: "請輸入密碼",
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
              controller: passwordController,
              // TODO: Assign a TextEditingController
            ),
            const SizedBox(height: 24), // 按鈕上方的間距

            ElevatedButton(
              onPressed: () {
                // TODO: Implement actual registration logic using the input from TextField controllers
                print('執行註冊...'); // 暫時印出訊息
                // 導向註冊頁面
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Register()),
                );

                // 註冊成功後可能導航到其他頁面或顯示訊息
                // Provider.of<AuthModel>(
                //   context,
                //   listen: false,
                // ).register(context, userNameController.text, userEmailController.text, passwordController.text);
                // 導向到登入頁面


              },
              child: const Text('註冊'),
            ),
          ],
        ),
      ),
    );
  }
}

*/