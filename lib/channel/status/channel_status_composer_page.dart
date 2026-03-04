import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:frontenduser/channel/status/channel_status_api.dart';
import 'package:frontenduser/core/channel_info_refresh_bus.dart';
import 'status_upload_controller.dart';

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

class _ChannelStatusComposerPageState
    extends State<ChannelStatusComposerPage> {

  VideoPlayerController? _videoController;
  final TextEditingController _captionController =
      TextEditingController();

  bool _isVideo = false;
  bool _uploading = false;

  // ================= INIT =================

  @override
  void initState() {
    super.initState();

    final path = widget.file.path.toLowerCase();

    _isVideo =
        path.endsWith(".mp4") ||
        path.endsWith(".mov") ||
        path.endsWith(".m4v");

    if (_isVideo) {
      _initVideo();
    }
  }

  Future<void> _initVideo() async {

    try {

      final controller =
          VideoPlayerController.file(widget.file);

      await controller.initialize();

      controller
        ..setLooping(true)
        ..play();

      _videoController = controller;

      if (mounted) setState(() {});

    } catch (_) {
      if (mounted) Navigator.pop(context);
    }
  }

  // ================= DISPOSE =================

  @override
  void dispose() {
    _videoController?.dispose();
    _captionController.dispose();
    super.dispose();
  }

  // ================= UPLOAD =================

  Future<void> _upload() async {

    if (_uploading) return;

    FocusScope.of(context).unfocus();

    setState(() => _uploading = true);

    StatusUploadController.instance
        .start(widget.channelId);

    try {

      await ChannelStatusApi.uploadStatus(
        channelId: widget.channelId,
        file: widget.file,
        type: _isVideo ? "VIDEO" : "IMAGE",
        caption: _captionController.text.trim(),
        onProgress: (progress) {
          StatusUploadController.instance
              .update(progress);
        },
      );

      StatusUploadController.instance.done();

      ChannelInfoRefreshBus.notify(widget.channelId);

      if (!mounted) return;

      Navigator.of(context)
          .popUntil((route) => route.isFirst);

    } catch (e) {

      StatusUploadController.instance.done();

      if (!mounted) return;

      setState(() => _uploading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Upload failed"),
        ),
      );
    }
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [

          /// MEDIA PREVIEW
          Positioned.fill(
            child: _isVideo
                ? _buildVideo()
                : Image.file(
                    widget.file,
                    fit: BoxFit.cover,
                  ),
          ),

          /// CLOSE BUTTON
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 10,
            child: IconButton(
              icon: const Icon(
                Icons.close,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),

          /// UPLOADING OVERLAY
          if (_uploading)
            const Positioned.fill(
              child: ColoredBox(
                color: Colors.black54,
                child: Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              ),
            ),

          /// CAPTION BAR
          Positioned(
            bottom: 30,
            left: 16,
            right: 16,
            child: SafeArea(
              child: Row(
                children: [

                  Expanded(
                    child: TextField(
                      controller: _captionController,
                      maxLines: 3,
                      minLines: 1,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      decoration: const InputDecoration(
                        hintText: "Add a caption…",
                        hintStyle: TextStyle(
                          color: Colors.white70,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  FloatingActionButton(
                    mini: true,
                    backgroundColor: Colors.blue,
                    onPressed:
                        _uploading ? null : _upload,
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

  Widget _buildVideo() {

    if (_videoController == null ||
        !_videoController!.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      );
    }

    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: _videoController!.value.size.width,
        height: _videoController!.value.size.height,
        child: VideoPlayer(_videoController!),
      ),
    );
  }
}