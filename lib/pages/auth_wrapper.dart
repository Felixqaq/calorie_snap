import 'package:flutter/material.dart';
import 'package:calorie_snap/pages/login_page.dart';
import 'package:calorie_snap/pages/register_page.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool showLoginPage = true;

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
