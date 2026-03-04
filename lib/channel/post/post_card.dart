import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:frontenduser/channel/media_preview/media_preview_page.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:url_launcher/url_launcher.dart';
import 'post_model.dart';

class PostCard extends StatelessWidget {
  final PostModel post;
  final VoidCallback? onUnlock;

  const PostCard({
    super.key,
    required this.post,
    this.onUnlock,
  });

  bool _isVideo(String type) => type == "VIDEO";
  bool _isImage(String type) => type == "IMAGE";
  bool _isAudio(String type) => type == "AUDIO";
  bool _isDocument(String type) => type == "DOCUMENT";

  bool get _shouldBlur =>
      post.type == "PAID" &&
      post.price > 0 &&
      !post.isUnlocked;

  @override
  Widget build(BuildContext context) {
    final hasMedia = post.media.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(
        left: 12,
        right: 110,
        top: 6,
        bottom: 6,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              blurRadius: 3,
              color: Colors.black12,
              offset: Offset(0, 1),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ================= MEDIA =================
            if (hasMedia)
              Padding(
                padding: const EdgeInsets.all(2),
                child: Stack(
                  children: [

                    _buildMediaLayout(context),

                    // 🔒 Blur if locked
                    if (_shouldBlur)
                      Positioned.fill(
                        child: GestureDetector(
                          onTap: onUnlock,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: BackdropFilter(
                              filter: ui.ImageFilter.blur(
                                sigmaX: 8,
                                sigmaY: 8,
                              ),
                              child: Container(
                                color: Colors.black.withOpacity(0.35),
                              ),
                            ),
                          ),
                        ),
                      ),

                    // ⭐ Star badge
                    if (post.type == "PAID" && post.price > 0)
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "${post.price}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    if (_shouldBlur)
                      const Positioned.fill(
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.lock,
                                  size: 40,
                                  color: Colors.white),
                              SizedBox(height: 6),
                              Text(
                                "Tap to unlock",
                                style: TextStyle(
                                    color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),

            // ================= TEXT =================
            // ================= TEXT =================
if (post.text.trim().isNotEmpty)
  Padding(
    padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
    child: Linkify(
      text: post.text,
      style: const TextStyle(
        fontSize: 15.5,
        height: 1.4,
        color: Colors.black,
      ),
      linkStyle: const TextStyle(
        color: Colors.blue,
        decoration: TextDecoration.underline,
      ),
      onOpen: (link) async {
  String url = link.url;

  // If scheme missing, add https
  if (!url.startsWith("http://") && !url.startsWith("https://")) {
    url = "https://$url";
  }

  final uri = Uri.parse(url);

  await launchUrl(uri);
},
    ),
  ),

            // ================= FOOTER =================
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(14, 0, 14, 10),
              child: Row(
                children: [
                  const Icon(
                    Icons.remove_red_eye_outlined,
                    size: 15,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    post.formattedViews,
                    style: const TextStyle(
                        color: Colors.grey),
                  ),
                  const Spacer(),

                  if (post.edited)
                    const Padding(
                      padding:
                          EdgeInsets.only(right: 6),
                      child: Text(
                        "edited",
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                          fontStyle:
                              FontStyle.italic,
                        ),
                      ),
                    ),

                  Text(
                    _formatTime(
                        post.updatedAt ??
                            post.createdAt),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= MEDIA GRID =================
  Widget _buildMediaLayout(BuildContext context) {
    final mediaList = post.media;
    final count = mediaList.length;

    if (count == 1) {
      return AspectRatio(
        aspectRatio: 1.2,
        child: _buildMediaItem(context, mediaList[0]),
      );
    }

    if (count == 2) {
      return Row(
        children: mediaList.map((m) {
          return Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: _buildMediaItem(context, m),
            ),
          );
        }).toList(),
      );
    }

    final itemWidth =
        (MediaQuery.of(context).size.width - 140) / 2;

    return Wrap(
      spacing: 2,
      runSpacing: 2,
      children: mediaList.map((m) {
        return SizedBox(
          width: itemWidth,
          height: 150,
          child: _buildMediaItem(context, m),
        );
      }).toList(),
    );
  }

  Widget _buildMediaItem(BuildContext context,dynamic media) {
  final String url =
      media.url.isNotEmpty
          ? media.url
          : (media.previewUrl ?? "");

  return GestureDetector(
    onTap: () {
      // 🔒 If locked, do nothing
      if (_shouldBlur) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MediaPreviewPage(media: media),
        ),
      );
    },
    child: _buildMediaContent(media, url),
  );
}

Widget _buildMediaContent(dynamic media, String url) {
  if (_isImage(media.type)) {
    return _buildImage(url);
  }

  if (_isVideo(media.type)) {
    return Stack(
      alignment: Alignment.center,
      children: [
        _buildImage(url),
        const Icon(
          Icons.play_circle_fill,
          size: 50,
          color: Colors.white,
        ),
      ],
    );
  }

  if (_isAudio(media.type)) {
    return const Center(
      child: Icon(Icons.audiotrack, size: 50),
    );
  }

  if (_isDocument(media.type)) {
    return const Center(
      child: Icon(Icons.insert_drive_file, size: 50),
    );
  }

  return const SizedBox();
}

  Widget _buildImage(String url) {

    if (url.isEmpty) {
      return const Center(
        child: Icon(Icons.broken_image,
            size: 40),
      );
    }

    if (!url.startsWith("http")) {
      return Image.file(
        File(url),
        fit: BoxFit.cover,
      );
    }

    return Image.network(
      url,
      fit: BoxFit.cover,
      loadingBuilder:
          (context, child, progress) {
        if (progress == null) return child;
        return const Center(
          child: CircularProgressIndicator(
              strokeWidth: 2),
        );
      },
      errorBuilder:
          (_, __, ___) =>
              const Center(
                  child: Icon(
                      Icons.broken_image)),
    );
  }

  String _formatTime(DateTime time) {
    return DateFormat('h:mm a').format(time);
  }
}