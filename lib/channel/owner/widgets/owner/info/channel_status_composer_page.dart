import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontenduser/core/channel_info_refresh_bus.dart';
import 'package:video_player/video_player.dart';
import 'package:frontenduser/channel/api/channel_status_api.dart';

class ChannelStatusComposerPage extends StatefulWidget {
  final String channelId;
  final File file;

  const ChannelStatusComposerPage({
    super.key,
    required this.channelId,
    required this.file,
  });

  @override
  State<ChannelStatusComposerPage> createState() =>
      _ChannelStatusComposerPageState();
}

class _ChannelStatusComposerPageState extends State<ChannelStatusComposerPage> {
  VideoPlayerController? _videoCtrl;
  final captionCtrl = TextEditingController();

  bool isVideo = false;
  double progress = 0;
  bool uploading = false;

  @override
  void initState() {
    super.initState();

    isVideo =
        widget.file.path.toLowerCase().endsWith(".mp4") ||
        widget.file.path.toLowerCase().endsWith(".mov") ||
        widget.file.path.toLowerCase().endsWith(".webm");

    if (isVideo) {
      _initVideo();
    }
  }

  Future<void> _initVideo() async {
    _videoCtrl = VideoPlayerController.file(widget.file);
    await _videoCtrl!.initialize();

    // ⛔ HARD ENFORCE 30s
    if (_videoCtrl!.value.duration > const Duration(seconds: 30)) {
      _videoCtrl!.seekTo(const Duration(seconds: 30));
    }

    _videoCtrl!
      ..setLooping(true)
      ..play();

    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _videoCtrl?.dispose();
    captionCtrl.dispose();
    super.dispose();
  }

  Future<void> _upload() async {
    if (uploading) return;

    setState(() {
      uploading = true;
      progress = 0;
    });

    try {
      await ChannelStatusApi.uploadStatus(
        channelId: widget.channelId,
        file: widget.file,
        type: isVideo ? "VIDEO" : "IMAGE",
        caption: captionCtrl.text.trim(),
        onProgress: (p) {
          if (mounted) setState(() => progress = p);
        },
      );

      ChannelInfoRefreshBus.notify(widget.channelId);

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Upload failed")));
    } finally {
      if (mounted) setState(() => uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ================= PREVIEW =================
          Positioned.fill(
            child: isVideo
                ? (_videoCtrl == null
                      ? const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      : AspectRatio(
                          aspectRatio: _videoCtrl!.value.aspectRatio,
                          child: VideoPlayer(_videoCtrl!),
                        ))
                : Image.file(widget.file, fit: BoxFit.cover),
          ),

          // ================= CLOSE =================
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 12,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // ================= PROGRESS =================
          if (uploading)
            Positioned(
              top: MediaQuery.of(context).padding.top + 56,
              left: 16,
              right: 16,
              child: LinearProgressIndicator(value: progress),
            ),

          // ================= CAPTION + SEND =================
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                12,
                8,
                12,
                MediaQuery.of(context).padding.bottom + 12,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black87],
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: captionCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: "Add a caption…",
                        hintStyle: TextStyle(color: Colors.white70),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  FloatingActionButton(
                    mini: true,
                    onPressed: uploading ? null : _upload,
                    child: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
