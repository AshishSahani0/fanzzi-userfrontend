import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'post_model.dart';
import 'post_api.dart';
import 'media_model.dart';

class EditPostPage extends StatefulWidget {
  final String channelId;
  final PostModel post;

  const EditPostPage({
    super.key,
    required this.channelId,
    required this.post,
  });

  @override
  State<EditPostPage> createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _textController;
  late TextEditingController _priceController;

  late List<MediaModel> media;

  bool isPaid = false;
  bool saving = false;

  bool get hasMediaPost => widget.post.media.isNotEmpty;

  bool get canEdit {
    final diff = DateTime.now().difference(widget.post.createdAt);
    return diff.inHours < 24;
  }

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.post.text);
    _priceController =
        TextEditingController(text: widget.post.price.toString());

    media = List.from(widget.post.media);
    isPaid = widget.post.type == "PAID";
  }

  // ==========================================================
  // 🔥 CORRECT MEDIA CHANGE DETECTION
  // ==========================================================
  bool _mediaChanged() {
    if (media.length != widget.post.media.length) return true;

    for (int i = 0; i < media.length; i++) {
      if (media[i].key != widget.post.media[i].key) {
        return true;
      }
    }

    return false;
  }

  // ================= ADD MEDIA =================
  Future<void> addMedia() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final file = File(picked.path);
    final uploaded = await PostApi.uploadMedia(file);

    setState(() {
      media.add(
        uploaded.copyWith(localPath: file.path),
      );
    });
  }

  // ================= REPLACE MEDIA =================
  Future<void> replaceMedia(int index) async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final file = File(picked.path);
    final uploaded = await PostApi.uploadMedia(file);

    setState(() {
      media[index] =
          uploaded.copyWith(localPath: file.path);
    });
  }

  // ================= SAFE MEDIA PREVIEW =================
  Widget _buildMediaPreview(MediaModel m) {
    if (m.localPath != null && m.localPath!.isNotEmpty) {
      return Image.file(
        File(m.localPath!),
        width: 110,
        height: 110,
        fit: BoxFit.cover,
      );
    }

    if (m.url.isNotEmpty && m.url.startsWith("http")) {
      return Image.network(
        m.url,
        width: 110,
        height: 110,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            const Icon(Icons.broken_image),
      );
    }

    return const SizedBox(
      width: 110,
      height: 110,
      child: Center(
        child: Icon(Icons.image),
      ),
    );
  }

  // ================= SAVE =================
  Future<void> save() async {
    if (!canEdit) return;

    final text = _textController.text.trim();
    final parsedPrice = int.tryParse(_priceController.text.trim());

    final bool textChanged = text != widget.post.text;
    final bool typeChanged = isPaid != widget.post.isPaid;
    final bool priceChanged = parsedPrice != widget.post.price;
    final bool mediaChanged = _mediaChanged(); // 🔥 FIXED

    if (isPaid && (parsedPrice == null || parsedPrice <= 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Price must be greater than 0")),
      );
      return;
    }

    if (isPaid && media.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Paid post must contain media")),
      );
      return;
    }

    if (!textChanged && !typeChanged && !priceChanged && !mediaChanged) {
      Navigator.pop(context);
      return;
    }

    setState(() => saving = true);

    try {
      final updated = await PostApi.editPost(
        channelId: widget.channelId,
        postId: widget.post.id,
        text: textChanged ? text : null,
        media: mediaChanged ? media : null,
        type: typeChanged ? (isPaid ? "PAID" : "FREE") : null,
        price: priceChanged ? parsedPrice : null,
      );

      if (!mounted) return;

      Navigator.pop(context, updated);
    } catch (_) {
      if (!mounted) return;

      setState(() => saving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Edit failed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!canEdit) {
      return Scaffold(
        appBar: AppBar(title: const Text("Edit Post")),
        body: const Center(
          child: Text(
            "Editing allowed only within 24 hours",
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Post"),
        actions: [
          TextButton(
            onPressed: saving ? null : save,
            child: saving
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text("Save"),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _textController,
              maxLines: null,
              decoration:
                  const InputDecoration(labelText: "Caption"),
            ),
            const SizedBox(height: 20),
            if (hasMediaPost) ...[
              if (media.isNotEmpty) ...[
                const Text(
                  "Tap media to replace",
                  style:
                      TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children:
                      List.generate(media.length, (index) {
                    final m = media[index];
                    return GestureDetector(
                      onTap: () => replaceMedia(index),
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(12),
                        child: _buildMediaPreview(m),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 15),
              ],
              OutlinedButton.icon(
                onPressed: addMedia,
                icon: const Icon(Icons.add),
                label: const Text("Add Media"),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  const Icon(Icons.star,
                      color: Colors.amber),
                  const SizedBox(width: 8),
                  const Text("Paid Post"),
                  const Spacer(),
                  Switch(
                    value: isPaid,
                    onChanged: (v) {
                      setState(() {
                        isPaid = v;
                      });
                    },
                  ),
                ],
              ),
              if (isPaid) ...[
                const SizedBox(height: 10),
                TextField(
                  controller: _priceController,
                  keyboardType:
                      TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: "Price (Stars)"),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}