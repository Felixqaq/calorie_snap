import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../utils/app_bar.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool _showCamera = false;

  @override
  void initState() {
    super.initState();
    _initializeControllerFuture = _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    _controller = CameraController(
      cameras.first,
      ResolutionPreset.medium,
    );
    return _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context, 'Calorie Snap'),
      body: Container(
        color: Colors.grey[200],
        child: _showCamera ? _buildCameraPreview() : _buildCameraButton(),
      ),
    );
  }

  Widget _buildCameraPreview() {
    return FutureBuilder<void>(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Stack(
            children: [
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: CameraPreview(_controller),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: FloatingActionButton(
                    onPressed: _onTakePictureButtonPressed,
                    child: const Icon(Icons.camera_alt),
                  ),
                ),
              ),
            ],
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _buildCameraButton() {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF2ECC71),
              Color(0xFF27AE60),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(75),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2ECC71).withAlpha(77),
              spreadRadius: 3,
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.all(30),
            shape: const CircleBorder(),
          ),
          onPressed: () {
            setState(() {
              _showCamera = true;
            });
          },
          child: const Icon(
            Icons.camera_enhance,
            size: 60,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Future<void> _onTakePictureButtonPressed() async {
    try {
      await _initializeControllerFuture;
      final image = await _controller.takePicture();
      if (!mounted) return;
      // TODO - Navigate to PhotoResultPage
    } catch (e) {
      debugPrint('拍照時發生錯誤: $e');
    }
  }
}