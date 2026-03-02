import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_waveforms/audio_waveforms.dart' hide PlayerState;
import 'package:photo_view/photo_view.dart';

class MediaPreviewPage extends StatefulWidget {
  final dynamic media;

  const MediaPreviewPage({super.key, required this.media});

  @override
  State<MediaPreviewPage> createState() => _MediaPreviewPageState();
}

class _MediaPreviewPageState extends State<MediaPreviewPage> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;

  final AudioPlayer _audioPlayer = AudioPlayer();
  PlayerController? _waveController;

  bool _loading = true;

  bool get _isVideo => widget.media.type == "VIDEO";
  bool get _isImage => widget.media.type == "IMAGE";
  bool get _isAudio => widget.media.type == "AUDIO";

  String get _url =>
      widget.media.url.isNotEmpty ? widget.media.url : "";

  @override
  void initState() {
    super.initState();
    _init();
  }

  // ============================================================
  // INITIALIZE MEDIA
  // ============================================================
  Future<void> _init() async {
    try {
      if (_isVideo) {
        _videoController = _url.startsWith("http")
            ? VideoPlayerController.networkUrl(Uri.parse(_url))
            : VideoPlayerController.file(File(_url));

        await _videoController!.initialize();

        _chewieController = ChewieController(
          videoPlayerController: _videoController!,
          autoPlay: true,
          looping: false,
          showControls: true,

          // 🔥 FULLSCREEN AUTO ROTATE
          deviceOrientationsOnEnterFullScreen: const [
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight,
          ],

          deviceOrientationsAfterFullScreen: const [
            DeviceOrientation.portraitUp,
          ],

          // Hide system UI in fullscreen
          systemOverlaysOnEnterFullScreen: [],
          systemOverlaysAfterFullScreen: SystemUiOverlay.values,
        );
      }

      if (_isAudio) {
        await _audioPlayer.setUrl(_url);

        _waveController = PlayerController();
        await _waveController!.preparePlayer(path: _url);
      }
    } catch (_) {}

    if (mounted) {
      setState(() => _loading = false);
    }
  }

  // ============================================================
  // CLEANUP + FORCE PORTRAIT RESET
  // ============================================================
  @override
  void dispose() {
    _videoController?.dispose();
    _chewieController?.dispose();
    _audioPlayer.dispose();
    _waveController?.dispose();

    // 🔄 Always reset to portrait when leaving preview
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    super.dispose();
  }

  // ============================================================
  // UI
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Center(child: _buildContent()),
    );
  }

  // ============================================================
  // CONTENT SWITCHER
  // ============================================================
  Widget _buildContent() {
    if (_isImage) {
      return PhotoView(
        backgroundDecoration:
            const BoxDecoration(color: Colors.black),
        imageProvider: _url.startsWith("http")
            ? NetworkImage(_url)
            : FileImage(File(_url)) as ImageProvider,
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 3,
      );
    }

    if (_isVideo && _chewieController != null) {
      return Chewie(controller: _chewieController!);
    }

    if (_isAudio) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AudioFileWaveforms(
            size: const Size(double.infinity, 100),
            playerController: _waveController!,
            waveformType: WaveformType.fitWidth,
            playerWaveStyle: const PlayerWaveStyle(
              liveWaveColor: Colors.blue,
              fixedWaveColor: Colors.grey,
            ),
          ),
          const SizedBox(height: 30),
          StreamBuilder(
            stream: _audioPlayer.playerStateStream,
            builder: (context, snapshot) {
              final playing = _audioPlayer.playing;

              return IconButton(
                iconSize: 64,
                color: Colors.white,
                icon: Icon(
                  playing
                      ? Icons.pause_circle
                      : Icons.play_circle,
                ),
                onPressed: () async {
                  if (playing) {
                    await _audioPlayer.pause();
                  } else {
                    await _audioPlayer.play();
                  }
                },
              );
            },
          ),
        ],
      );
    }

    return const Text(
      "Unsupported media",
      style: TextStyle(color: Colors.white),
    );
  }
}