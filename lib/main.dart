import 'package:calorie_snap/pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'pages/food_page.dart';
import 'pages/show_today_intake_page.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'providers/calorie_provider.dart';
import 'package:calorie_snap/pages/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    ChangeNotifierProvider(
      create: (_) => CalorieProvider(),
      child: const MyApp(),
    ),
  );
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final seedColor = const Color(0xFF4CAF50);
    
    return MaterialApp(
      title: 'Calorie Snap',
      builder: (context, child) {
        // 獲取當前主題顏色
        final ThemeData theme = Theme.of(context);
        // 設置系統導航列顏色與主題一致
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          systemNavigationBarColor: Theme.of(context).colorScheme.surface,
          systemNavigationBarIconBrightness: Brightness.dark,
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: theme.brightness == Brightness.dark ? Brightness.light : Brightness.dark,
        ));
        return child!;
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.transparent,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
      routes: {
        '/show_food': (context) => const FoodPage(title: 'Food Record'),
        '/show_today_intake': (context) => const ShowTodayIntakePage(),
        '/register': (context) => RegisterPage(
          onTap: () => Navigator.pushReplacementNamed(context, '/login'),
        ),
        '/login': (context) => const LoginPage(),
        '/profile': (context) => const ProfilePage(),
      },
      home: const AuthWrapper(),
    );
  }
}
