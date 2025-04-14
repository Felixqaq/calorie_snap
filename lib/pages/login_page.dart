import 'package:calorie_snap/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'home_page.dart';
import 'package:calorie_snap/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  late AnimationController _animController;
  late Animation<double> _opacityAnimation;
  final _storageService = StorageService();
  final AuthService _authService = AuthService();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
    _animController.forward();
    
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final userEmail = await _storageService.read(key: 'userEmail');
    if (userEmail != null) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      setState(() => _isLoading = true);
      
      final userCredential = await _authService.signInWithGoogle();
      if (userCredential == null) {
        setState(() => _isLoading = false);
        return;
      }
      
      final user = userCredential.user;
      if (user == null) {
        throw Exception('無法獲取使用者資訊');
      }

      await _storageService.write(key: 'userId', value: user.uid);
      await _storageService.write(key: 'userEmail', value: user.email ?? '');
      await _storageService.write(key: 'userName', value: user.displayName ?? '');
      await _storageService.write(key: 'userPhoto', value: user.photoURL ?? '');

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('登入失敗: ${error.toString()}')),
      );
      setState(() => _isLoading = false);
    }
  }

  void _skipLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(seconds: 3),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [theme.primaryColor, theme.colorScheme.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _opacityAnimation,
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.camera, size: 72, color: Theme.of(context).primaryColor),
                    const SizedBox(height: 16),
                    Text(
                      'Calorie Snap',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '飲食紀錄，輕鬆掌控',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                    const SizedBox(height: 32),
                    
                    // 谷歌登入按鈕
                    _isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 32),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              minimumSize: const Size(double.infinity, 48),
                            ),
                            onPressed: _handleGoogleSignIn,
                            icon: Image.network(
                                'http://pngimg.com/uploads/google/google_PNG19635.png',
                                height: 24,
                                width: 24,
                            ),
                            label: const Text(
                              '使用 Google 登入',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                    const SizedBox(height: 20),
                    
                    // 跳過登入按鈕
                    TextButton(
                      onPressed: _skipLogin,
                      style: TextButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      child: const Text(
                        '不使用帳號，直接進入',
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                    ),
                    
                    // 移除了電子郵件登入表單和註冊選項
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}