import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

typedef UploadFunction = Future<String> Function(File file);

class ProfileImage extends StatefulWidget {
  final String imageUrl;
  final double radius;
  final UploadFunction? onUpload;

  const ProfileImage({
    super.key,
    required this.imageUrl,
    this.radius = 70,
    this.onUpload,
  });

  @override
  State<ProfileImage> createState() => _ProfileImageState();
}

class _ProfileImageState extends State<ProfileImage> {
  bool uploading = false;
  File? localFile;
  String? uploadedUrl;

  // =========================================================
  // 📷 PICK IMAGE
  // =========================================================

  Future<void> _pickImage(ImageSource source) async {
    final picked = await ImagePicker().pickImage(source: source);

    if (picked == null) return;

    final file = File(picked.path);

    setState(() {
      uploading = true;
      localFile = file;
    });

    try {
      if (widget.onUpload != null) {
        final url = await widget.onUpload!(file);
        if (!mounted) return;

        setState(() => uploadedUrl = url);
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Upload failed: $e")),
      );
    } finally {
      if (mounted) setState(() => uploading = false);
    }
  }

  // =========================================================
  // 📂 IMAGE SOURCE PICKER
  // =========================================================

  void _showPicker() {
    if (widget.onUpload == null) return;

    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text("Camera"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Gallery"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // 🖼️ IMAGE PROVIDER LOGIC
  // =========================================================

  ImageProvider? _getProvider() {
    if (localFile != null) return FileImage(localFile!);
    if (uploadedUrl != null) return NetworkImage(uploadedUrl!);
    if (widget.imageUrl.isNotEmpty) return NetworkImage(widget.imageUrl);
    return null;
  }

  // =========================================================
  // 🎨 UI
  // =========================================================

  @override
  Widget build(BuildContext context) {
    final provider = _getProvider();

    return GestureDetector(
      onTap: _showPicker,
      child: Stack(
        alignment: Alignment.center,
        children: [

          /// ⭐ AVATAR
          CircleAvatar(
            radius: widget.radius,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: provider,
            child: provider == null
                ? Icon(Icons.person, size: widget.radius)
                : null,
          ),

          /// ⭐ UPLOAD LOADING OVERLAY
          if (uploading)
            CircleAvatar(
              radius: widget.radius,
              backgroundColor: Colors.black54,
              child: const CircularProgressIndicator(
                color: Colors.white,
              ),
            ),

          /// ⭐ CAMERA BUTTON
          if (widget.onUpload != null && !uploading)
            Positioned(
              bottom: 4,
              right: 4,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).primaryColor,
                ),
                padding: const EdgeInsets.all(8),
                child: const Icon(
                  Icons.camera_alt,
                  size: 18,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}