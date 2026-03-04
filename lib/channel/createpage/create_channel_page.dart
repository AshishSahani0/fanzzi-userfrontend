import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'channel_media_api.dart';
import 'channel_create_api.dart';
import 'create_channel_request.dart';

class CreateChannelPage extends StatefulWidget {
  const CreateChannelPage({super.key});

  @override
  State<CreateChannelPage> createState() => _CreateChannelPageState();
}

class _CreateChannelPageState extends State<CreateChannelPage> {
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _desc = TextEditingController();
  final _price = TextEditingController();

  final ValueNotifier<bool> _loading = ValueNotifier(false);

  File? _imageFile;
  String _visibility = "PUBLIC";
  String _type = "FREE";

  // ================= IMAGE =================

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80, // compress → faster upload
    );

    if (picked != null && mounted) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  // ================= SUBMIT =================

  Future<void> _submit() async {
    if (_loading.value) return;

    if (!_formKey.currentState!.validate()) return;

    _loading.value = true;

    try {
      int? monthlyPrice;

      if (_type == "PAID") {
        monthlyPrice = int.parse(_price.text.trim());
      }

      String? profileKey;

      if (_imageFile != null) {
        profileKey =
            await ChannelMediaApi.uploadChannelProfile(_imageFile!);
      }

      final req = CreateChannelRequest(
        name: _name.text.trim(),
        description: _desc.text.trim().isEmpty
            ? null
            : _desc.text.trim(),
        profileImageKey: profileKey,
        visibility: _visibility,
        type: _type,
        monthlyPrice: monthlyPrice,
        discoverable: true,
      );

      await ChannelCreateApi.createChannel(req);

      if (!mounted) return;

      Navigator.pop(context, {"refresh": true});
    } catch (e) {
      if (!mounted) return;
      _show(e.toString());
    } finally {
      _loading.value = false;
    }
  }

  void _show(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    _name.dispose();
    _desc.dispose();
    _price.dispose();
    _loading.dispose();
    super.dispose();
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      appBar: AppBar(
        title: const Text("Create Channel"),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [

            // Avatar
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage:
                      _imageFile != null ? FileImage(_imageFile!) : null,
                  child: _imageFile == null
                      ? const Icon(Icons.camera_alt, size: 28)
                      : null,
                ),
              ),
            ),

            const SizedBox(height: 24),

            _Input(
              controller: _name,
              label: "Channel Name",
              validator: (v) =>
                  v == null || v.trim().isEmpty
                      ? "Channel name required"
                      : null,
            ),

            const SizedBox(height: 16),

            _Input(
              controller: _desc,
              label: "Description",
              maxLines: 3,
            ),

            const SizedBox(height: 24),

            _SectionTitle("Visibility"),
            const SizedBox(height: 8),
            _ChipSelector(
              value: _visibility,
              options: const ["PUBLIC", "PRIVATE"],
              onChanged: (v) => setState(() => _visibility = v),
            ),

            const SizedBox(height: 24),

            _SectionTitle("Channel Type"),
            const SizedBox(height: 8),
            _ChipSelector(
              value: _type,
              options: const ["FREE", "PAID"],
              onChanged: (v) => setState(() => _type = v),
            ),

            if (_type == "PAID") ...[
              const SizedBox(height: 16),
              _Input(
                controller: _price,
                label: "Monthly Price (₹)",
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (_type != "PAID") return null;
                  final val = int.tryParse(v ?? "");
                  if (val == null || val <= 0) {
                    return "Invalid price";
                  }
                  return null;
                },
              ),
            ],

            const SizedBox(height: 32),

            ValueListenableBuilder<bool>(
              valueListenable: _loading,
              builder: (_, loading, __) {
                return SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: loading ? null : _submit,
                    child: loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text("Create Channel"),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Input extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _Input({
    required this.controller,
    required this.label,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
    );
  }
}

class _ChipSelector extends StatelessWidget {
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  const _ChipSelector({
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: options
          .map(
            (e) => ChoiceChip(
              label: Text(e),
              selected: value == e,
              onSelected: (_) => onChanged(e),
            ),
          )
          .toList(),
    );
  }
}