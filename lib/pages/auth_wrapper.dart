import 'package:flutter/material.dart';
import 'package:calorie_snap/pages/login_page.dart';
import 'package:calorie_snap/pages/register_page.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  // 控制顯示登入或註冊頁面
  bool showLoginPage = true;

  // 切換頁面的方法
  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return LoginPageWrapper(onTap: togglePages);
    } else {
      return RegisterPage(onTap: togglePages);
    }
  }
}

// 包裝現有的 LoginPage，添加切換功能
class LoginPageWrapper extends StatelessWidget {
  final Function()? onTap;
  
  const LoginPageWrapper({Key? key, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const LoginPage(),
        ],
      ),
    );
  }
}
