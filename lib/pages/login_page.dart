import 'package:calorie_snap/pages/register_page.dart';
import 'package:calorie_snap/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _errorMessage = '';

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
    
    // 檢查是否已登入
    _checkLoginStatus();
  }

  // 檢查使用者是否已經登入
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

      // 儲存使用者資料時進行明確的型別轉換
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

  Future<void> _signInWithEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final userCredential = await _authService.signInWithEmailPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      final user = userCredential.user;
      if (user == null) {
        throw Exception('無法獲取使用者資訊');
      }

      // 儲存使用者資料時進行明確的型別轉換
      await _storageService.write(key: 'userId', value: user.uid);
      await _storageService.write(key: 'userEmail', value: user.email ?? '');
      await _storageService.write(key: 'userName', value: user.displayName ?? '');
      await _storageService.write(key: 'userPhoto', value: user.photoURL ?? '');

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        switch (e.code) {
          case 'user-not-found':
            _errorMessage = '找不到此Email帳號';
            break;
          case 'wrong-password':
            _errorMessage = '密碼錯誤';
            break;
          case 'invalid-email':
            _errorMessage = 'Email格式不正確';
            break;
          default:
            _errorMessage = '登入失敗：${e.message}';
        }
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
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
                child: Form(
                  key: _formKey,
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
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: '電子郵件',
                          prefixIcon: const Icon(Icons.email),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '請輸入電子郵件';
                          }
                          if (!EmailValidator.validate(value.trim())) {
                            return '請輸入有效的電子郵件地址';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: '密碼',
                          prefixIcon: const Icon(Icons.lock),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '請輸入密碼';
                          }
                          return null;
                        },
                      ),
                      if (_errorMessage.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            _errorMessage,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _signInWithEmail,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('使用 Email 登入'),
                      ),
                      const SizedBox(height: 16),
                      const Text('或', style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 16),
                      _isLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 32),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
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
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: _skipLogin,
                        child: const Text(
                          '不使用帳號，直接進入',
                          style: TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '還沒有帳號？',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RegisterPage(
                                    onTap: () => Navigator.pop(context),
                                  ),
                                ),
                              );
                            },
                            child: const Text(
                              '註冊',
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}