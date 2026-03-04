import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontenduser/channel/status/channel_status_api.dart';
import 'package:frontenduser/channel/status/channel_status_model.dart';
import 'package:frontenduser/channel/status/views/channel_status_views_button.dart';
import 'package:video_player/video_player.dart';

class ChannelStatusViewerPage extends StatefulWidget {
  final String channelId;

  const ChannelStatusViewerPage({super.key, required this.channelId});

  @override
  State<ChannelStatusViewerPage> createState() =>
      _ChannelStatusViewerPageState();
}

class _ChannelStatusViewerPageState extends State<ChannelStatusViewerPage>
    with TickerProviderStateMixin {

  List<ChannelStatusModel> statuses = [];
  int index = 0;

  VideoPlayerController? videoCtrl;
  Timer? imageTimer;

  late AnimationController progressController;

  bool loading = true;

  static const imageDuration = Duration(seconds: 5);

  /// ================= INIT =================

  @override
  void initState() {
    super.initState();

    progressController =
        AnimationController(vsync: this, duration: imageDuration)
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              _next();
            }
          });

    _load();
  }

  Future<void> _load() async {

    final data = await ChannelStatusApi.fetchActive(widget.channelId);

    if (!mounted) return;

    if (data.isEmpty) {
      Navigator.pop(context);
      return;
    }

    setState(() {
      statuses = data;
      index = 0;
      loading = false;
    });

    _playCurrent();
  }

  /// ================= PLAY =================

  void _playCurrent() {

    if (statuses.isEmpty) return;

    imageTimer?.cancel();
    videoCtrl?.dispose();
    videoCtrl = null;

    progressController.stop();
    progressController.reset();

    final status = statuses[index];

    /// mark viewed
    if (!status.viewed) {
  status.viewed = true;
  ChannelStatusApi.markViewed(widget.channelId, status.id);
}

    /// TEXT or IMAGE timer
    if (status.type == "TEXT" || status.type == "IMAGE") {
      progressController.duration = imageDuration;
      progressController.forward();
      setState(() {});
      return;
    }

    /// VIDEO
    if (status.type == "VIDEO" && status.mediaUrls.isNotEmpty) {

      videoCtrl = VideoPlayerController.network(status.mediaUrls.first)
        ..initialize().then((_) {

          if (!mounted) return;

          progressController.duration = videoCtrl!.value.duration;

          videoCtrl!.play();
          progressController.forward();

          videoCtrl!.addListener(() {

            final pos = videoCtrl!.value.position;
            final dur = videoCtrl!.value.duration;

            if (dur != Duration.zero) {
              final value =
                  pos.inMilliseconds / dur.inMilliseconds;

              progressController.value =
                  value.clamp(0.0, 1.0);
            }

            if (pos >= dur) {
              _next();
            }
          });

          setState(() {});
        });
    }
  }

  /// ================= NAVIGATION =================

  void _next() {

    if (index < statuses.length - 1) {
      setState(() => index++);
      _playCurrent();
    } else {
      Navigator.pop(context);
    }
  }

  void _previous() {

    if (index > 0) {
      setState(() => index--);
      _playCurrent();
    }
  }

  void _pause() {
    progressController.stop();
    videoCtrl?.pause();
  }

  void _resume() {
    progressController.forward();
    videoCtrl?.play();
  }

  /// ================= DISPOSE =================

  @override
  void dispose() {
    progressController.dispose();
    imageTimer?.cancel();
    videoCtrl?.dispose();
    super.dispose();
  }

  /// ================= UI =================

  @override
  Widget build(BuildContext context) {

    if (loading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    final status = statuses[index];

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(

        onTapUp: (details) {

          final width = MediaQuery.of(context).size.width;
          final dx = details.localPosition.dx;

          if (dx < width / 2) {
            _previous();
          } else {
            _next();
          }
        },

        onLongPressStart: (_) => _pause(),
        onLongPressEnd: (_) => _resume(),

        child: Stack(
          children: [

            /// MEDIA
            Positioned.fill(
              child: _buildContent(status),
            ),

            /// PROGRESS BARS
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 8,
              right: 8,
              child: Row(
                children: List.generate(
                  statuses.length,
                  (i) => Expanded(
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 2),
                      child: _buildSegment(i),
                    ),
                  ),
                ),
              ),
            ),

            /// CLOSE
            Positioned(
              top: MediaQuery.of(context).padding.top + 24,
              left: 12,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),

            /// VIEW BUTTON
            Positioned(
              bottom: 16,
              right: 16,
              child: ChannelStatusViewsButton(
                channelId: widget.channelId,
                statusId: status.id,
                viewCount: status.viewCount,
                isOwner: true,
              ),
            ),

            /// CAPTION
            if (status.text != null && status.text!.isNotEmpty)
              Positioned(
                left: 16,
                right: 16,
                bottom: 60,
                child: Text(
                  status.text!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegment(int i) {

    if (i < index) {
      return _segment(1);
    } else if (i == index) {
      return AnimatedBuilder(
        animation: progressController,
        builder: (_, __) => _segment(progressController.value),
      );
    } else {
      return _segment(0);
    }
  }

  Widget _segment(double value) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: LinearProgressIndicator(
        value: value,
        backgroundColor: Colors.white24,
        valueColor:
            const AlwaysStoppedAnimation<Color>(Colors.white),
        minHeight: 3,
      ),
    );
  }

  Widget _buildContent(ChannelStatusModel status) {

    /// TEXT
    if (status.type == "TEXT") {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            status.text ?? "",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    /// IMAGE
    if (status.type == "IMAGE") {

      if (status.mediaUrls.isEmpty) {
        return const Center(
          child: Text(
            "Image unavailable",
            style: TextStyle(color: Colors.white),
          ),
        );
      }

      return Image.network(
        status.mediaUrls.first,
        fit: BoxFit.cover,
      );
    }

    /// VIDEO
    if (status.type == "VIDEO") {

      if (status.mediaUrls.isEmpty) {
        return const Center(
          child: Text(
            "Video unavailable",
            style: TextStyle(color: Colors.white),
          ),
        );
      }

      if (videoCtrl == null || !videoCtrl!.value.isInitialized) {
        return const Center(
          child: CircularProgressIndicator(color: Colors.white),
        );
      }

      return FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: videoCtrl!.value.size.width,
          height: videoCtrl!.value.size.height,
          child: VideoPlayer(videoCtrl!),
        ),
      );
    }

    return const SizedBox();
  }
}