import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:calorie_snap/services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  
  const RegisterPage({Key? key, this.onTap}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final AuthService _authService = AuthService();
  // 表單的全域鍵，用於驗證
  final _formKey = GlobalKey<FormState>();
  
  // 文字控制器
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  
  // 錯誤訊息
  String errorMessage = '';
  
  // 使用條款同意狀態
  bool agreedToTerms = false;
  
  // 密碼強度狀態
  double _passwordStrength = 0;
  String _passwordStrengthText = '請輸入密碼';
  Color _passwordStrengthColor = Colors.grey;
  
  // 載入狀態
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  // 檢查密碼強度
  void _checkPasswordStrength(String password) {
    if (password.isEmpty) {
      setState(() {
        _passwordStrength = 0;
        _passwordStrengthText = '請輸入密碼';
        _passwordStrengthColor = Colors.grey;
      });
      return;
    }
    
    // 計算密碼強度 (簡易版)
    double strength = 0;
    
    // 至少8個字元
    if (password.length >= 8) strength += 0.25;
    
    // 包含大寫字母
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.25;
    
    // 包含數字
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.25;
    
    // 包含特殊字元
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.25;

    setState(() {
      _passwordStrength = strength;
      
      if (strength < 0.25) {
        _passwordStrengthText = '非常弱';
        _passwordStrengthColor = Colors.red;
      } else if (strength < 0.5) {
        _passwordStrengthText = '弱';
        _passwordStrengthColor = Colors.orangeAccent;
      } else if (strength < 0.75) {
        _passwordStrengthText = '中等';
        _passwordStrengthColor = Colors.yellow[800]!;
      } else if (strength < 1) {
        _passwordStrengthText = '強';
        _passwordStrengthColor = Colors.green[300]!;
      } else {
        _passwordStrengthText = '非常強';
        _passwordStrengthColor = Colors.green;
      }
    });
  }

  // 註冊功能
  Future<void> signUp() async {
    // 先驗證表單
    if (!_formKey.currentState!.validate()) return;
    
    // 檢查是否同意使用條款
    if (!agreedToTerms) {
      setState(() {
        errorMessage = '您必須同意使用條款才能註冊';
      });
      return;
    }
    
    // 設置載入狀態
    setState(() {
      errorMessage = '';
      isLoading = true;
    });
    
    // 檢查密碼與確認密碼是否一致
    if (passwordController.text != confirmPasswordController.text) {
      setState(() {
        errorMessage = '密碼與確認密碼不符';
        isLoading = false;
      });
      return;
    }
    
    try {
      // 創建使用者
      await _authService.registerWithEmailPassword(
        emailController.text,
        passwordController.text
      );
      
      if (!mounted) return;
      Navigator.pop(context); // 返回登入頁
      
    } catch (e) {
      setState(() {
        errorMessage = '註冊失敗: ${e.toString()}';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 50),
                    
                    // Logo
                    const Icon(
                      Icons.app_registration_rounded,
                      size: 100,
                    ),
                    
                    const SizedBox(height: 50),
                    
                    // 歡迎文字
                    Text(
                      '建立您的帳號',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 16,
                      ),
                    ),
                    
                    const SizedBox(height: 25),
                    
                    // 電子郵件輸入
                    TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade400),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade700),
                        ),
                        errorBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red),
                        ),
                        focusedErrorBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade200,
                        hintText: '電子郵件',
                        prefixIcon: Icon(Icons.email, color: Colors.grey[700]),
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
                    
                    const SizedBox(height: 10),
                    
                    // 密碼輸入
                    TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade400),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade700),
                        ),
                        errorBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red),
                        ),
                        focusedErrorBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade200,
                        hintText: '密碼',
                        prefixIcon: Icon(Icons.lock, color: Colors.grey[700]),
                      ),
                      onChanged: _checkPasswordStrength,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '請輸入密碼';
                        }
                        if (value.length < 8) {
                          return '密碼長度至少為8個字元';
                        }
                        if (_passwordStrength < 0.5) {
                          return '密碼強度不足，請混合使用大寫字母、數字和特殊符號';
                        }
                        return null;
                      },
                    ),
                    
                    // 密碼強度提示
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: LinearProgressIndicator(
                              value: _passwordStrength,
                              backgroundColor: Colors.grey[300],
                              color: _passwordStrengthColor,
                              minHeight: 5,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            _passwordStrengthText,
                            style: TextStyle(
                              color: _passwordStrengthColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 10),
                    
                    // 確認密碼輸入
                    TextFormField(
                      controller: confirmPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade400),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade700),
                        ),
                        errorBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red),
                        ),
                        focusedErrorBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade200,
                        hintText: '確認密碼',
                        prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[700]),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '請確認您的密碼';
                        }
                        if (value != passwordController.text) {
                          return '密碼不符合';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 15),
                    
                    // 使用條款同意選項
                    Row(
                      children: [
                        Checkbox(
                          value: agreedToTerms,
                          onChanged: (value) {
                            setState(() {
                              agreedToTerms = value ?? false;
                            });
                          },
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              // 顯示使用條款和隱私政策
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('使用條款與隱私政策'),
                                  content: const SingleChildScrollView(
                                    child: Text(
                                      '使用本應用程式即表示您同意我們的使用條款和隱私政策。\n\n'
                                      '我們會收集一些個人資料以提供更好的服務，但我們承諾會妥善保護您的隱私。',
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text('了解'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: const Text(
                              '我同意使用條款和隱私政策',
                              style: TextStyle(
                                fontSize: 14,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 10),
                    
                    // 錯誤訊息
                    if (errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 15.0),
                        child: Text(
                          errorMessage,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    
                    // 註冊按鈕
                    ElevatedButton(
                      onPressed: isLoading ? null : signUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        minimumSize: const Size(double.infinity, 50),
                        disabledBackgroundColor: Colors.grey,
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            )
                          : const Text(
                              '註冊',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                    ),
                    
                    const SizedBox(height: 25),
                    
                    // 切換到登入頁面
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '已經有帳號？',
                          style: TextStyle(
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: widget.onTap,
                          child: const Text(
                            '登入',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 50),
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
