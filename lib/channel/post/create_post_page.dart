import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class CreatePostPage extends StatefulWidget {
  final String channelId;
  final List<String>? initialFiles;
  final String? initialText;

  const CreatePostPage({
    super.key,
    required this.channelId,
    this.initialFiles,
    this.initialText,
  });

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final captionController = TextEditingController();
  final PageController pageController = PageController();

  List<File> files = [];
  int currentIndex = 0;

  bool isPaid = false;
  int price = 0;

  VideoPlayerController? videoController;

  @override
  void initState() {
    super.initState();

    if (widget.initialFiles != null) {
      files = widget.initialFiles!.map((p) => File(p)).toList();
    }

    if (widget.initialText != null) {
      captionController.text = widget.initialText!;
    }

    _initVideoIfNeeded();
  }

  void _initVideoIfNeeded() async {
    if (files.isEmpty) return;

    final ext = files[currentIndex].path.toLowerCase();

    if (_isVideo(ext)) {
      videoController =
          VideoPlayerController.file(files[currentIndex]);
      await videoController!.initialize();
      setState(() {});
    }
  }

  bool _isVideo(String path) =>
      path.endsWith(".mp4") ||
      path.endsWith(".mov") ||
      path.endsWith(".webm");

  bool _isImage(String path) =>
      path.endsWith(".png") ||
      path.endsWith(".jpg") ||
      path.endsWith(".jpeg") ||
      path.endsWith(".webp");

  bool _isAudio(String path) =>
      path.endsWith(".mp3") ||
      path.endsWith(".wav");

  bool _isDocument(String path) =>
      path.endsWith(".pdf") ||
      path.endsWith(".doc") ||
      path.endsWith(".docx");

  void _removeFile(int index) {
    setState(() {
      files.removeAt(index);
      if (currentIndex >= files.length) {
        currentIndex = files.length - 1;
      }
    });
  }

  Future<void> publish() async {
    Navigator.pop(context, {
      "files": files,
      "text": captionController.text.trim(),
      "isPaid": isPaid,
      "price": price,
    });
  }

  @override
  void dispose() {
    videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasMedia = files.isNotEmpty;

    return Scaffold(
      backgroundColor: hasMedia ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: hasMedia ? Colors.black : Colors.white,
        foregroundColor: hasMedia ? Colors.white : Colors.black,
        elevation: 0,
        title: const Text("Create Post"),
      ),
      body: Column(
        children: [

          // ================= MAIN PREVIEW =================
          if (hasMedia)
            Expanded(
              child: Stack(
                children: [
                  PageView.builder(
                    controller: pageController,
                    itemCount: files.length,
                    onPageChanged: (i) {
                      setState(() {
                        currentIndex = i;
                        videoController?.dispose();
                        videoController = null;
                      });
                      _initVideoIfNeeded();
                    },
                    itemBuilder: (_, index) {
                      final file = files[index];
                      final path = file.path.toLowerCase();

                      if (_isImage(path)) {
                        return Image.file(file,
                            fit: BoxFit.contain);
                      }

                      if (_isVideo(path)) {
                        if (videoController == null ||
                            !videoController!
                                .value.isInitialized) {
                          return const Center(
                              child:
                                  CircularProgressIndicator());
                        }

                        return GestureDetector(
                          onTap: () {
                            if (videoController!
                                .value.isPlaying) {
                              videoController!.pause();
                            } else {
                              videoController!.play();
                            }
                            setState(() {});
                          },
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              AspectRatio(
                                aspectRatio: videoController!
                                    .value.aspectRatio,
                                child: VideoPlayer(
                                    videoController!),
                              ),
                              if (!videoController!
                                  .value.isPlaying)
                                const Icon(Icons.play_circle,
                                    size: 80,
                                    color: Colors.white),
                            ],
                          ),
                        );
                      }

                      if (_isAudio(path)) {
                        return const Center(
                          child: Icon(Icons.audiotrack,
                              size: 100,
                              color: Colors.white),
                        );
                      }

                      if (_isDocument(path)) {
                        return const Center(
                          child: Icon(Icons.insert_drive_file,
                              size: 100,
                              color: Colors.white),
                        );
                      }

                      return const SizedBox();
                    },
                  ),

                  // REMOVE BUTTON
                  Positioned(
                    top: 20,
                    right: 20,
                    child: IconButton(
                      icon: const Icon(Icons.close,
                          color: Colors.white),
                      onPressed: () =>
                          _removeFile(currentIndex),
                    ),
                  ),
                ],
              ),
            ),

          // ================= THUMBNAIL STRIP =================
          if (hasMedia && files.length > 1)
            SizedBox(
              height: 70,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: files.length,
                itemBuilder: (_, index) {
                  return GestureDetector(
                    onTap: () {
                      pageController.jumpToPage(index);
                    },
                    child: Container(
                      margin: const EdgeInsets.all(6),
                      width: 60,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: index == currentIndex
                              ? Colors.blue
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Image.file(files[index],
                          fit: BoxFit.cover),
                    ),
                  );
                },
              ),
            ),

          // ================= CAPTION + ACTION =================
          Container(
            padding: const EdgeInsets.all(12),
            color: hasMedia
                ? Colors.black87
                : Colors.grey.shade100,
            child: Column(
              children: [
                TextField(
                  controller: captionController,
                  style: TextStyle(
                      color:
                          hasMedia ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    hintText: "Add a caption...",
                    hintStyle: TextStyle(
                        color: hasMedia
                            ? Colors.white54
                            : Colors.black54),
                    border: InputBorder.none,
                  ),
                ),
                const SizedBox(height: 8),

// 🔒 Paid Toggle
Row(
  children: [
    Switch(
      value: isPaid,
      onChanged: (value) {
        setState(() {
          isPaid = value;
          if (!isPaid) price = 0;
        });
      },
    ),
    Text(
      "Paid Post",
      style: TextStyle(
        color: hasMedia ? Colors.white : Colors.black,
      ),
    ),
  ],
),

// 💰 Price Field (only if paid)
if (isPaid)
  Padding(
    padding: const EdgeInsets.only(top: 6),
    child: TextField(
      keyboardType: TextInputType.number,
      style: TextStyle(
        color: hasMedia ? Colors.white : Colors.black,
      ),
      decoration: InputDecoration(
        hintText: "Enter price",
        hintStyle: TextStyle(
          color: hasMedia ? Colors.white54 : Colors.black54,
        ),
        border: InputBorder.none,
      ),
      onChanged: (value) {
        price = int.tryParse(value) ?? 0;
      },
    ),
  ),

const SizedBox(height: 8),

Row(
  children: [
    const Spacer(),
    IconButton(
      icon: const Icon(Icons.send, color: Colors.blue),
      onPressed: () {
        if (isPaid && price <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Please enter valid price"),
            ),
          );
          return;
        }
        publish();
      },
    ),
  ],
),
              ],
            ),
          ),
        ],
      ),
    );
  }
}