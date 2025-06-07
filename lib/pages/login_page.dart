import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController(); // 註冊用
  bool _isLogin = true; // 切換登入/註冊模式

  void _authenticate() async {
    final authModel = Provider.of<AuthModel>(context, listen: false);
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String? username = _usernameController.text.trim();

    if (_isLogin) {
      // 登入邏輯
      LoginError error = await authModel.login(email, password);
      if (error.error == Errorlog.success) {
        if (mounted) {
          // 導航到主頁面（假設有 HomePage）
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error.message)),
          );
        }
      }
    } else {
      // 註冊邏輯
      try {
        await authModel.register(context, username!, email, password);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('註冊成功')),
          );
          // 註冊成功後，如果已經認證，直接導航到主頁面
          if (authModel.isAuthenticated) {
            Navigator.pushReplacementNamed(context, '/home');
          } else {
            setState(() {
              _isLogin = true; // 切換回登入模式，讓用戶手動登入
            });
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('註冊失敗: $e')),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isLogin ? '登入頁面' : '註冊頁面')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            if (!_isLogin) ...[
              const SizedBox(height: 10),
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
              ),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _authenticate,
              child: Text(_isLogin ? '登入' : '註冊'),
            ),
            Text("---------------OR---------------"),
            TextButton(
              onPressed: () {
                setState(() {
                  _isLogin = !_isLogin;
                  _emailController.clear();
                  _passwordController.clear();
                  _usernameController.clear();
                });
              },
              child: Text(_isLogin ? '註冊新帳號' : '返回登入'),
            ),
          ],
        ),
      ),
    );
  }
}