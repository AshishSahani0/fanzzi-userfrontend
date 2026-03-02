import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontenduser/channel/api/channel_status_api.dart';
import 'package:frontenduser/channel/model/channel_status_model.dart';
import 'package:video_player/video_player.dart';

class ChannelStatusViewerPage extends StatefulWidget {
  final String channelId;

  const ChannelStatusViewerPage({super.key, required this.channelId});

  @override
  State<ChannelStatusViewerPage> createState() =>
      _ChannelStatusViewerPageState();
}

class _ChannelStatusViewerPageState extends State<ChannelStatusViewerPage> {
  List<ChannelStatusModel> statuses = [];
  int index = 0;
  VideoPlayerController? videoCtrl;
  Timer? imageTimer;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    statuses = await ChannelStatusApi.fetchActive(widget.channelId);

    if (!mounted) return;

    if (statuses.isEmpty) {
      Navigator.pop(context);
      return;
    }

    _playCurrent();
  }

  void _playCurrent() {
    imageTimer?.cancel();
    videoCtrl?.dispose();

    final status = statuses[index];

    if (status.type == "IMAGE") {
      imageTimer = Timer(const Duration(seconds: 5), _next);
      setState(() {});
    } else {
      videoCtrl = VideoPlayerController.network(status.mediaUrl)
        ..initialize().then((_) {
          videoCtrl!.play();
          videoCtrl!.addListener(() {
            if (videoCtrl!.value.position >= videoCtrl!.value.duration) {
              _next();
            }
          });
          setState(() {});
        });
    }
  }

  void _next() {
    if (index < statuses.length - 1) {
      setState(() => index++);
      _playCurrent();
    } else {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    imageTimer?.cancel();
    videoCtrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final status = statuses[index];

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _next,
        child: Stack(
          children: [
            Positioned.fill(
              child: status.type == "IMAGE"
                  ? Image.network(status.mediaUrl, fit: BoxFit.cover)
                  : (videoCtrl == null
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                        : FittedBox(
                            fit: BoxFit.cover,
                            child: SizedBox(
                              width: videoCtrl!.value.size.width,
                              height: videoCtrl!.value.size.height,
                              child: VideoPlayer(videoCtrl!),
                            ),
                          )),
            ),

            // ❌ CLOSE
            Positioned(
              top: MediaQuery.of(context).padding.top + 12,
              left: 12,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),

            // 💬 CAPTION
            if (status.caption != null)
              Positioned(
                left: 16,
                right: 16,
                bottom: 40,
                child: Text(
                  status.caption!,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
