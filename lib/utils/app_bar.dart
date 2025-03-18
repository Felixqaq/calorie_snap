import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:calorie_snap/services/auth_service.dart';
import 'package:calorie_snap/services/storage_service.dart';
import 'package:calorie_snap/pages/login_page.dart';

AppBar buildAppBar(BuildContext context, String title) {
  final authService = AuthService();
  final user = authService.currentUser;

  return AppBar(
    backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
    elevation: Theme.of(context).appBarTheme.elevation,
    leading: IconButton(
      icon: Icon(Icons.menu, color: Theme.of(context).disabledColor),
      onPressed: () {
        Scaffold.of(context).openDrawer();
      },
    ),
    title: Text(
      title,
      style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
        color: Theme.of(context).primaryColor,
      ),
    ),
    centerTitle: Theme.of(context).appBarTheme.centerTitle,
    actions: [
      _buildAccountButton(context, user, authService),
    ],
  );
}

Widget _buildAccountButton(BuildContext context, User? user, AuthService authService) {
  if (user != null) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 45),
      icon: CircleAvatar(
        backgroundImage: user.photoURL != null 
          ? NetworkImage(user.photoURL!) 
          : null,
        child: user.photoURL == null 
          ? Text(user.displayName?[0].toUpperCase() ?? user.email?[0].toUpperCase() ?? 'U')
          : null,
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'profile',
          child: ListTile(
            leading: const Icon(Icons.person),
            title: Text('個人資料'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        PopupMenuItem(
          value: 'settings',
          child: ListTile(
            leading: const Icon(Icons.settings),
            title: Text('設定'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'logout',
          child: ListTile(
            leading: const Icon(Icons.logout),
            title: Text('登出'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
      onSelected: (value) => _handleMenuSelection(context, value, authService),
    );
  } else {
    return TextButton.icon(
      icon: const Icon(Icons.login),
      label: const Text('登入'),
      onPressed: () => Navigator.pushNamed(context, '/login'),
      style: TextButton.styleFrom(
        foregroundColor: Theme.of(context).primaryColor,
      ),
    );
  }
}

void _handleMenuSelection(BuildContext context, String value, AuthService authService) async {
  final storageService = StorageService();
  
  switch (value) {
    case 'profile':
      Navigator.pushNamed(context, '/profile');
      break;
    case 'settings':
      Navigator.pushNamed(context, '/settings');
      break;
    case 'logout':
      try {
        await authService.signOut();
        // 清除本地保存的使用者資料
        await storageService.deleteAll();

        if (!context.mounted) return;

        // 導航回登入頁面
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('登出時發生錯誤: $e')),
        );
      }
      break;
  }
}