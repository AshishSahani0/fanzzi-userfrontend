import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:frontenduser/channel/createpage/channel_media_api.dart';
import 'package:frontenduser/channel/createpage/channel_create_api.dart';
import 'package:frontenduser/channel/createpage/create_channel_request.dart';

class CreateChannelPage extends StatefulWidget {
  const CreateChannelPage({super.key});

  @override
  State<CreateChannelPage> createState() => _CreateChannelPageState();
}

class _CreateChannelPageState extends State<CreateChannelPage> {
  final nameController = TextEditingController();
  final descController = TextEditingController();
  final priceController = TextEditingController();

  File? imageFile;

  String visibility = "PUBLIC";
  String type = "FREE";

  bool loading = false;

  // ================= PICK IMAGE =================

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (picked != null && mounted) {
      setState(() => imageFile = File(picked.path));
    }
  }

  // ================= CREATE CHANNEL =================

  Future<void> submitChannel() async {
    if (loading) return;

    final name = nameController.text.trim();

    if (name.isEmpty) {
      showMsg("Channel name is required");
      return;
    }

    setState(() => loading = true);

    try {
      int? monthlyPrice;

      if (type == "PAID") {
        monthlyPrice = int.tryParse(priceController.text.trim());

        if (monthlyPrice == null || monthlyPrice <= 0) {
          throw "Monthly price must be greater than 0";
        }
      }

      String? profileKey;

      if (imageFile != null) {
        profileKey = await ChannelMediaApi.uploadChannelProfile(imageFile!);
      }

      final request = CreateChannelRequest(
        name: name,
        description: descController.text.trim().isEmpty
            ? null
            : descController.text.trim(),
        profileImageKey: profileKey,
        visibility: visibility,
        type: type,
        monthlyPrice: type == "PAID" ? monthlyPrice : null,
        category: null,
        language: null,
        discoverable: true,
      );

      await ChannelCreateApi.createChannel(request);

      if (!mounted) return;

      Navigator.of(context).pop({"goToChats": true, "refresh": true});
    } catch (e) {
      if (mounted) showMsg(e.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    nameController.dispose();
    descController.dispose();
    priceController.dispose();
    super.dispose();
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    final primary = Colors.blue.shade700;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      appBar: AppBar(
        title: const Text("Create Channel"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ================= CHANNEL AVATAR =================
            Center(
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: pickImage,
                    child: CircleAvatar(
                      radius: 56,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: imageFile != null
                          ? FileImage(imageFile!)
                          : null,
                      child: imageFile == null
                          ? Icon(
                              Icons.camera_alt,
                              size: 30,
                              color: Colors.grey.shade600,
                            )
                          : null,
                    ),
                  ),

                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: primary,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(8),
                      child: const Icon(
                        Icons.edit,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 26),

            // ================= BASIC INFO =================
            _sectionCard(
              child: Column(
                children: [
                  _input(controller: nameController, label: "Channel Name"),
                  const SizedBox(height: 14),
                  _input(
                    controller: descController,
                    label: "Description",
                    maxLines: 3,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // ================= VISIBILITY =================
            _sectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle("Visibility"),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    children: [
                      _visibilityChip("PUBLIC", "Public"),
                      _visibilityChip("PRIVATE", "Private"),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // ================= CHANNEL TYPE =================
            _sectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle("Channel Type"),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    children: [
                      _typeChip("FREE", "Free"),
                      _typeChip("PAID", "Paid"),
                    ],
                  ),

                  if (type == "PAID") ...[
                    const SizedBox(height: 16),
                    _input(
                      controller: priceController,
                      label: "Monthly Price (₹)",
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Subscribers will pay monthly to access this channel",
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ================= CREATE BUTTON =================
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: loading ? null : submitChannel,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  disabledBackgroundColor: primary.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: loading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        "Create Channel",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= HELPERS =================

  Widget _sectionCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    );
  }

  Widget _input({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFF7F8FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _visibilityChip(String key, String label) {
    return ChoiceChip(
      label: Text(label),
      selected: visibility == key,
      onSelected: (_) => setState(() => visibility = key),
    );
  }

  Widget _typeChip(String key, String label) {
    return ChoiceChip(
      label: Text(label),
      selected: type == key,
      onSelected: (_) => setState(() => type = key),
    );
  }
}
