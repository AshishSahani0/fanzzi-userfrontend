import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:frontenduser/main.dart'; // IMPORTANT (globalCameras)

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? controller;

  bool isRecording = false;
  bool isRearCamera = true;
  FlashMode flashMode = FlashMode.off;
  bool initializing = true;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    if (globalCameras.isEmpty) {
      setState(() => initializing = false);
      return;
    }

    final camera = globalCameras.firstWhere(
      (cam) =>
          cam.lensDirection ==
          (isRearCamera
              ? CameraLensDirection.back
              : CameraLensDirection.front),
      orElse: () => globalCameras.first,
    );

    controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: true,
    );

    try {
      await controller!.initialize();
      await controller!.setFlashMode(flashMode);
    } catch (e) {
      debugPrint("Camera error: $e");
    }

    if (!mounted) return;

    setState(() => initializing = false);
  }

  // ================= PHOTO =================
  Future<void> _capturePhoto() async {
    if (controller == null ||
        !controller!.value.isInitialized ||
        isRecording) return;

    final file = await controller!.takePicture();
    if (!mounted) return;

    Navigator.pop(context, File(file.path));
  }

  // ================= VIDEO =================
  Future<void> _startRecording() async {
    if (controller == null ||
        !controller!.value.isInitialized ||
        isRecording) return;

    await controller!.startVideoRecording();
    setState(() => isRecording = true);
  }

  Future<void> _stopRecording() async {
    if (!isRecording) return;

    final file = await controller!.stopVideoRecording();
    setState(() => isRecording = false);

    if (!mounted) return;
    Navigator.pop(context, File(file.path));
  }

  // ================= SWITCH CAMERA =================
  Future<void> _switchCamera() async {
    if (globalCameras.length < 2) return;

    isRearCamera = !isRearCamera;
    await controller?.dispose();
    setState(() => initializing = true);
    await _initCamera();
  }

  // ================= FLASH =================
  Future<void> _toggleFlash() async {
    if (controller == null) return;

    flashMode =
        flashMode == FlashMode.off ? FlashMode.torch : FlashMode.off;

    await controller!.setFlashMode(flashMode);
    setState(() {});
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (initializing) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (controller == null || !controller!.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            "Camera not available",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [

          Positioned.fill(
            child: CameraPreview(controller!),
          ),

          // ================= TOP CONTROLS =================
          Positioned(
            top: 50,
            right: 20,
            child: Column(
              children: [
                IconButton(
                  icon: Icon(
                    flashMode == FlashMode.off
                        ? Icons.flash_off
                        : Icons.flash_on,
                    color: Colors.white,
                  ),
                  onPressed: _toggleFlash,
                ),
                IconButton(
                  icon: const Icon(
                    Icons.cameraswitch,
                    color: Colors.white,
                  ),
                  onPressed: _switchCamera,
                ),
              ],
            ),
          ),

          // ================= RECORD BUTTON =================
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _capturePhoto,
                onLongPressStart: (_) => _startRecording(),
                onLongPressEnd: (_) => _stopRecording(),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: isRecording ? 90 : 75,
                  height: isRecording ? 90 : 75,
                  decoration: BoxDecoration(
                    color:
                        isRecording ? Colors.red : Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}