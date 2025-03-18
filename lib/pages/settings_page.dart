import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text('通知設定'),
            trailing: Switch(
              value: true,
              onChanged: (value) {
                // 處理通知設定
              },
            ),
          ),
          ListTile(
            leading: Icon(Icons.dark_mode),
            title: Text('深色模式'),
            trailing: Switch(
              value: Theme.of(context).brightness == Brightness.dark,
              onChanged: (value) {
                // 處理主題切換
              },
            ),
          ),
          // 其他設定選項...
        ],
      ),
    );
  }
}
