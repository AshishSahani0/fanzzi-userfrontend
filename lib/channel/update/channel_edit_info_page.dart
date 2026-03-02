import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontenduser/channel/update/channel_update_api.dart';
import 'package:frontenduser/channel/update/update_channel_request.dart';
import 'package:frontenduser/profile/image_picker_util.dart';
import 'package:frontenduser/channel/createpage/channel_media_api.dart';
import 'package:frontenduser/channel/model/channel_model.dart';
import 'package:frontenduser/auth/config/api_client.dart';

class ChannelEditInfoPage extends StatefulWidget {
  final ChannelModel channel;

  const ChannelEditInfoPage({super.key, required this.channel});

  @override
  State<ChannelEditInfoPage> createState() => _ChannelEditInfoPageState();
}

class _ChannelEditInfoPageState extends State<ChannelEditInfoPage> {
  late TextEditingController name;
  late TextEditingController description;
  late TextEditingController priceController;

  String type = "";
  String visibility = "";

  String? avatarKey;
  String? avatarUrl;

  bool uploadingAvatar = false;
  bool saving = false;

  @override
  void initState() {
    super.initState();

    name = TextEditingController(text: widget.channel.name);
    description =
        TextEditingController(text: widget.channel.description ?? "");

    type = widget.channel.type ?? "FREE";
    visibility = widget.channel.visibility ?? "PUBLIC";

    // ✅ IMPORTANT FIX — Prefill price from DB
    priceController = TextEditingController(
      text: widget.channel.monthlyPrice != null
          ? widget.channel.monthlyPrice.toString()
          : "",
    );

    avatarKey = widget.channel.profileImageKey;
    avatarUrl = widget.channel.profileImageUrl;
  }

  @override
  void dispose() {
    name.dispose();
    description.dispose();
    priceController.dispose();
    super.dispose();
  }

  // =====================================================
  // 🖼 CHANGE AVATAR
  // =====================================================
  Future<void> _changeAvatar() async {
    final File? file = await ImagePickerUtil.pickImage();
    if (file == null) return;

    setState(() => uploadingAvatar = true);

    try {
      final key = await ChannelMediaApi.uploadChannelProfile(file);

      setState(() {
        avatarKey = key;
        avatarUrl = ApiClient.buildPublicUrl(key);
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Upload failed: $e")));
    } finally {
      if (mounted) setState(() => uploadingAvatar = false);
    }
  }

  // =====================================================
  // 💾 SAVE CHANGES
  // =====================================================
  Future<void> _save() async {
    if (saving) return;

    setState(() => saving = true);

    try {
      final req = UpdateChannelRequest(
        name: name.text.trim(),
        description: description.text.trim(),
        visibility: visibility,
        type: type,
        profileImageKey: avatarKey,
        monthlyPrice: type == "PAID"
            ? int.tryParse(priceController.text)
            : null,
      );

      await ChannelUpdateApi.updateChannel(widget.channel.id, req);

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Update failed: $e")));
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  // =====================================================
  // UI
  // =====================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: const Text("Channel Settings"),
        actions: [
          TextButton(
            onPressed: saving ? null : _save,
            child: saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    "Save",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
          ),
        ],
      ),
      body: ListView(
        children: [
          _header(),
          const SizedBox(height: 18),

          _sectionTitle("Information"),
          _input(name, "Channel Name"),
          _input(description, "Description", maxLines: 3),

          const SizedBox(height: 18),

          _sectionTitle("Settings"),
          _dropdownField("Visibility", visibility, const {
            "PUBLIC": "Public",
            "PRIVATE": "Private",
          }, (v) {
            setState(() => visibility = v);
          }),

          _dropdownField("Channel Type", type, const {
            "FREE": "Free",
            "PAID": "Paid Subscription",
          }, (v) {
            setState(() => type = v);

            // 🔥 Optional: clear price if switching to FREE
            if (v == "FREE") {
              priceController.clear();
            }
          }),

          if (type == "PAID") ...[
            _sectionTitle("Monetization"),
            _input(
              priceController,
              "Monthly Price",
              keyboardType: TextInputType.number,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Subscribers must pay monthly to access this channel",
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ),
          ],

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // =====================================================
  // HEADER
  // =====================================================
  Widget _header() {
    return Container(
      padding: const EdgeInsets.only(top: 32, bottom: 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2D7CF6), Color(0xFF5A9BFF)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 54,
                backgroundColor: Colors.white,
                backgroundImage:
                    avatarUrl != null ? NetworkImage(avatarUrl!) : null,
                child: avatarUrl == null
                    ? const Icon(Icons.camera_alt, size: 32)
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: FloatingActionButton(
                  mini: true,
                  onPressed: uploadingAvatar ? null : _changeAvatar,
                  child: uploadingAvatar
                      ? const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        )
                      : const Icon(Icons.edit),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            name.text,
            style: const TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // UI HELPERS
  // =====================================================
  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          color: Colors.grey,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _input(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget _dropdownField(
    String label,
    String value,
    Map<String, String> items,
    Function(String) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        items: items.entries
            .map((e) => DropdownMenuItem(
                  value: e.key,
                  child: Text(e.value),
                ))
            .toList(),
        onChanged: (v) => onChanged(v!),
      ),
    );
  }
}