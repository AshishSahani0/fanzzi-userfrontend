import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'channel_status_composer_page.dart';

class ChannelStatusCameraPage extends StatefulWidget {
  final String channelId;

  const ChannelStatusCameraPage({
    super.key,
    required this.channelId,
  });

  @override
  State<ChannelStatusCameraPage> createState() =>
      _ChannelStatusCameraPageState();
}

class _ChannelStatusCameraPageState
    extends State<ChannelStatusCameraPage>
    with WidgetsBindingObserver {

  CameraController? _controller;
  List<CameraDescription> _cameras = [];

  int _cameraIndex = 0;
  bool _initializing = true;
  bool _recording = false;
  bool _flash = false;

  Timer? _recordTimer;
  int _seconds = 0;

  static const int _maxDuration = 60;

  // ================= INIT =================

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setup();
  }

  Future<void> _setup() async {
    try {
      _cameras = await availableCameras();

      if (_cameras.isEmpty) return;

      await _initCamera(_cameras[_cameraIndex]);

      if (mounted) {
        setState(() => _initializing = false);
      }
    } catch (_) {
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _initCamera(CameraDescription description) async {
    await _controller?.dispose();

    final controller = CameraController(
      description,
      ResolutionPreset.medium, // 🔥 medium = faster + lighter
      enableAudio: true,
    );

    _controller = controller;
    await controller.initialize();
  }

  // ================= LIFECYCLE =================

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null) return;

    if (state == AppLifecycleState.inactive) {
      _controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera(_cameras[_cameraIndex]);
    }
  }

  // ================= PHOTO =================

  Future<void> _capture() async {
    if (!_ready) return;

    final file = await _controller!.takePicture();
    _openPreview(File(file.path));
  }

  // ================= VIDEO =================

  Future<void> _startRecording() async {
    if (!_ready || _recording) return;

    await _controller!.startVideoRecording();

    _recording = true;
    _seconds = 0;

    _recordTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        _seconds++;

        if (_seconds >= _maxDuration) {
          _stopRecording();
        }

        if (mounted) setState(() {});
      },
    );

    setState(() {});
  }

  Future<void> _stopRecording() async {
    if (!_recording) return;

    final file = await _controller!.stopVideoRecording();

    _recordTimer?.cancel();
    _recording = false;
    _seconds = 0;

    if (mounted) setState(() {});

    await Future.delayed(const Duration(milliseconds: 250));
    _openPreview(File(file.path));
  }

  // ================= GALLERY =================

  Future<void> _openGallery() async {
    final picker = ImagePicker();
    final media = await picker.pickMedia();
    if (media == null) return;

    _openPreview(File(media.path));
  }

  // ================= SWITCH CAMERA =================

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;

    _cameraIndex = _cameraIndex == 0 ? 1 : 0;

    setState(() => _initializing = true);

    await _initCamera(_cameras[_cameraIndex]);

    if (mounted) {
      setState(() => _initializing = false);
    }
  }

  // ================= FLASH =================

  Future<void> _toggleFlash() async {
    if (!_ready) return;

    _flash = !_flash;

    await _controller!.setFlashMode(
      _flash ? FlashMode.torch : FlashMode.off,
    );

    setState(() {});
  }

  // ================= PREVIEW =================

  void _openPreview(File file) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChannelStatusComposerPage(
          channelId: widget.channelId,
          file: file,
        ),
      ),
    );
  }

  bool get _ready =>
      _controller != null &&
      _controller!.value.isInitialized;

  // ================= DISPOSE =================

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _recordTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    if (_initializing || !_ready) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onVerticalDragEnd: (_) => _openGallery(),
        child: Stack(
          children: [

            /// CAMERA
            Positioned.fill(
              child: CameraPreview(_controller!),
            ),

            /// TOP BAR
            Positioned(
              top: MediaQuery.of(context).padding.top + 12,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close,
                        color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  IconButton(
                    icon: Icon(
                      _flash
                          ? Icons.flash_on
                          : Icons.flash_off,
                      color: Colors.white,
                    ),
                    onPressed: _toggleFlash,
                  ),
                ],
              ),
            ),

            /// TIMER
            if (_recording)
              Positioned(
                top:
                    MediaQuery.of(context).padding.top + 70,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    "$_seconds s",
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            /// CONTROLS
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  const Text(
                    "Swipe up for gallery",
                    style:
                        TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.photo_library,
                          color: Colors.white,
                        ),
                        onPressed: _openGallery,
                      ),
                      GestureDetector(
                        onTap: _capture,
                        onLongPressStart: (_) =>
                            _startRecording(),
                        onLongPressEnd: (_) =>
                            _stopRecording(),
                        child: CircleAvatar(
                          radius: 35,
                          backgroundColor: _recording
                              ? Colors.red
                              : Colors.white,
                        ),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}