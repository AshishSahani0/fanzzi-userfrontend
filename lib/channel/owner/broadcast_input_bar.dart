import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:frontenduser/channel/post/create_post_page.dart';

class BroadcastInputBar extends StatefulWidget {
  final String channelId;
  final Function(Map data) onPost;

  const BroadcastInputBar({
    super.key,
    required this.channelId,
    required this.onPost,
  });

  @override
  State<BroadcastInputBar> createState() => _BroadcastInputBarState();
}

class _BroadcastInputBarState extends State<BroadcastInputBar> {
  final controller = TextEditingController();

  // =====================================================
  // ✅ SEND TEXT
  // =====================================================
  void sendText() {
    final text = controller.text.trim();
    if (text.isEmpty) return;

    controller.clear();

    widget.onPost({
      "files": <File>[],
      "text": text,
      "isPaid": false,
      "price": 0,
    });
  }

  // =====================================================
  // 📎 GALLERY (CUSTOM PREVIEW ONLY)
  // =====================================================
  Future<void> pickGallery() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.media, // 🔥 IMPORTANT FIX
    );

    if (result == null || result.files.isEmpty) return;

    final paths = result.files
        .where((f) => f.path != null)
        .map((f) => f.path!)
        .toList();

    if (paths.isEmpty) return;

    if (!mounted) return;

    final preview = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreatePostPage(
          channelId: widget.channelId,
          initialFiles: paths,
        ),
      ),
    );

    if (preview != null) {
      widget.onPost(preview);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasText = controller.text.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          // 📎 GALLERY
          IconButton(
            icon: const Icon(Icons.attach_file),
            onPressed: pickGallery,
          ),

          // ✏️ INPUT
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: "Broadcast...",
                  border: InputBorder.none,
                ),
                minLines: 1,
                maxLines: 4,
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => sendText(),
              ),
            ),
          ),

          const SizedBox(width: 6),

          // 🚀 SEND BUTTON
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: hasText ? Colors.blue : Colors.grey.shade300,
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: hasText ? sendText : null,
            ),
          ),
        ],
      ),
    );
  }
}