import 'package:flutter/material.dart';
import 'pages/show_food_page.dart';
import 'pages/camera_page.dart';  // 新增這行

void main() {
  runApp(const MyApp());
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
        '/show_food': (context) => const ShowFoodPage(title: 'Calorie Snap'),
      },
      home: const CameraPage(),
    );
  }
}