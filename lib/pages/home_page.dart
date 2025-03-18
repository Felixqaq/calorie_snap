import 'package:flutter/material.dart';
import 'package:calorie_snap/pages/login_page.dart';
import 'food_page.dart';
import 'show_today_intake_page.dart';
import 'search_food_page.dart';
import 'package:calorie_snap/services/auth_service.dart';  // 新增引入
import 'package:calorie_snap/services/storage_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;
  final _storageService = StorageService();
  final AuthService _authService = AuthService();

  // 處理登出功能
  Future<void> _handleLogout() async {
    // 顯示確認對話框
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('確認登出'),
        content: const Text('您確定要登出嗎？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('確定'),
          ),
        ],
      ),
    ) ?? false;

    if (!confirm) return;

    try {
      // 登出 (使用 AuthService)
      await _authService.signOut();

      // 清除本地保存的使用者資料
      await _storageService.deleteAll();

      if (!mounted) return;

      // 導航回登入頁面
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    } catch (error) {
      if (!mounted) return;

      // 顯示錯誤訊息
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('登出時發生錯誤: ${error.toString()}')),
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _scaffoldKey.currentState?.closeDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera,
                    color: Colors.white,
                    size: 50,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Calorie Snap',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.home,
                  color: Theme.of(context).colorScheme.primary),
              title: const Text('Today\'s Intake'),
              selected: _selectedIndex == 0,
              onTap: () => _onItemTapped(0),
            ),
            ListTile(
              leading: Icon(Icons.search,
                  color: Theme.of(context).colorScheme.primary),
              title: const Text('Search Food'),
              selected: _selectedIndex == 1,
              onTap: () => _onItemTapped(1),
            ),
            ListTile(
              leading: Icon(Icons.list,
                  color: Theme.of(context).colorScheme.primary),
              title: const Text('Intake Record'),
              selected: _selectedIndex == 2,
              onTap: () => _onItemTapped(2),
            ),
            // 在導航選單中新增登出選項
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('登出'),
              onTap: _handleLogout,
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          ShowTodayIntakePage(),
          SearchFoodPage(),
          FoodPage(title: 'Food Record'),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home,
                color: Theme.of(context).colorScheme.primary),
            label: 'Today\'s Intake',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search,
                color: Theme.of(context).colorScheme.primary),
            label: 'Search Food',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list,
                color: Theme.of(context).colorScheme.primary),
            label: 'Intake Record',
          ),
        ],
      ),
    );
  }
}
