import 'package:flutter/material.dart';
import 'package:calorie_snap/services/auth_service.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('個人資料'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: user?.photoURL != null 
              ? NetworkImage(user!.photoURL!) 
              : null,
            child: user?.photoURL == null 
              ? Text(user?.email?[0].toUpperCase() ?? 'U')
              : null,
          ),
          const SizedBox(height: 16),
          ListTile(
            title: Text('電子郵件'),
            subtitle: Text(user?.email ?? ''),
          ),
          // 其他個人資料欄位...
        ],
      ),
    );
  }
}
