import 'package:flutter/material.dart';
import 'dart:io';  // 新增這行來使用 File

class PhotoResultPage extends StatelessWidget {
  final String imagePath;

  const PhotoResultPage({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('照片結果'),
      ),
      body: Center(
        child: Image.file(
          File(imagePath),
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
