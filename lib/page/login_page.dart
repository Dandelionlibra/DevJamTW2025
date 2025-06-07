import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:Wandering/auth.dart';
import 'preference_selection_page.dart';
import 'package:flutter/gestures.dart'; // 用於處理文字點擊事件
import 'all_page.dart'; // 匯入所有頁面



class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController userEmailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool agreeTerms = false;

  Future<void> _showError(BuildContext context, LoginError error) async {
    // 當登入失敗時顯示錯誤訊息
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error.message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                const SizedBox(height: 40),
                // Logo 圖示
                Image.asset('assets/images/wandering_5.PNG', height: 200, width: 200), // 你可替換為設計圖中的圖片
                const SizedBox(height: 10),
                const Text(
                  '你只要出發，剩下交給我。',
                  style: TextStyle(
                    fontFamily: 'ChenYuluoyan', // 使用自定義字體
                    color: Color.fromARGB(255, 6, 48, 66),
                    fontSize: 20,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 30),

                // 帳號欄位
                _grayBorderedField(
                  child: _roundedInputField(controller: userEmailController, hint: '帳號', obscure: false),
                ),
                const SizedBox(height: 16),

                _grayBorderedField(
                  child: _roundedInputField(controller: passwordController, hint: '密碼', obscure: true),
                ),
                const SizedBox(height: 8),

                // 忘記密碼
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // TODO: 忘記密碼邏輯
                    },
                    child: const Text(
                      '忘記密碼？',
                      style: TextStyle(color: Colors.cyanAccent),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // 登入按鈕（漸層）
                GestureDetector(
                  onTap: () {
                    if (agreeTerms) {
                      Provider.of<AuthModel>(context, listen: false)
                          .login(
                        userEmailController.text,
                        passwordController.text,
                      )
                          .then((error) {
                        if (error != Errorlog.success) {
                          _showError(context, error);
                        }
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('請先同意使用條款與隱私政策')),
                      );
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF7beec5), // 薄荷綠
                          Color(0xFF01e6fa), // 亮藍
                          Color(0xFF32c8ff), // 天藍
                          Color(0xFFc0e8cb), // 淡綠
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        '登入',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Expanded(
                      child: Divider(
                        color: Colors.grey,
                        thickness: 1,
                        endIndent: 10,
                      ),
                    ),
                    const Text(
                      'or',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const Expanded(
                      child: Divider(
                        color: Colors.grey,
                        thickness: 1,
                        indent: 10,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 註冊按鈕（白色圓角）
                OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Register()),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.grey),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 40),
                  ),
                  child: const Text(
                    '註冊',
                    style: TextStyle(color: Colors.cyanAccent),
                  ),
                ),
                const SizedBox(height: 24),

                // 條款 Checkbox
                Row(
                  children: [
                    Checkbox(
                      value: agreeTerms,
                      onChanged: (value) {
                        setState(() {
                          agreeTerms = value ?? false;
                        });
                      },
                      activeColor: Colors.cyanAccent,
                    ),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 4.0), // 或左右 padding
                        child: Text.rich(
                          TextSpan(
                            style: const TextStyle(fontSize: 10, color: Colors.black45),
                            children: [
                              const TextSpan(text: '勾選即表示你同意 Wandering 的'),
                              TextSpan(
                                text: '《使用條款》',
                                style: const TextStyle(color: Colors.cyanAccent, decoration: TextDecoration.underline),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    _showPolicyDialog(context, '使用條款');
                                  },
                              ),
                              const TextSpan(text: ' 和 '),
                              TextSpan(
                                text: '《隱私政策》',
                                style: const TextStyle(color: Colors.cyanAccent, decoration: TextDecoration.underline),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    _showPolicyDialog(context, '隱私政策');
                                  },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
  void _showPolicyDialog(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: const Text('暫時還沒想好 :)'),
        actions: [
          TextButton(
            child: const Text('關閉'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
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

  Widget _roundedInputField({
    required TextEditingController controller, // 控制輸入文字的控制器
    required String hint,
    required bool obscure, // 是否隱藏輸入內容（如密碼）
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

