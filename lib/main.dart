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
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calorie Snap',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4CAF50),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
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
      },
      home: const AuthWrapper(),
    );
  }
}
