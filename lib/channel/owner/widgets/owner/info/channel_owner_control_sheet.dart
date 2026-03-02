import 'package:flutter/material.dart';
import 'package:frontenduser/channel/model/channel_model.dart';
import 'package:frontenduser/channel/update/channel_update_api.dart';
import 'package:frontenduser/channel/update/update_channel_request.dart';

class ChannelOwnerControlSheet extends StatefulWidget {
  final ChannelModel channel;

  const ChannelOwnerControlSheet({super.key, required this.channel});

  static void open(BuildContext context, ChannelModel channel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => ChannelOwnerControlSheet(channel: channel),
    );
  }

  @override
  State<ChannelOwnerControlSheet> createState() =>
      _ChannelOwnerControlSheetState();
}

class _ChannelOwnerControlSheetState
    extends State<ChannelOwnerControlSheet> {

  String? category;
  String? language;
  bool discoverable = true;
  bool nsfw = false;

  bool saving = false;

  @override
  void initState() {
    super.initState();

    // 🔥 No dependency on ChannelModel extra fields
    // Start with defaults
    category = null;
    language = null;
    discoverable = true;
    nsfw = false;
  }

  Future<void> _save() async {
    if (saving) return;

    setState(() => saving = true);

    try {
      await ChannelUpdateApi.updateChannel(
        widget.channel.id,
        UpdateChannelRequest(
          category: category,
          language: language,
          discoverable: discoverable,
          isNsfw: nsfw,
        ),
      );

      if (!mounted) return;
      Navigator.pop(context, true);

    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Update failed: $e")));
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              const Text(
                "Channel Control",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 24),

              // ================= CATEGORY =================
              DropdownButtonFormField<String>(
                value: category,
                decoration: const InputDecoration(
                  labelText: "Category",
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: "TECH", child: Text("Tech")),
                  DropdownMenuItem(value: "EDUCATION", child: Text("Education")),
                  DropdownMenuItem(value: "GAMING", child: Text("Gaming")),
                  DropdownMenuItem(value: "BUSINESS", child: Text("Business")),
                  DropdownMenuItem(value: "OTHER", child: Text("Other")),
                ],
                onChanged: (v) => setState(() => category = v),
              ),

              const SizedBox(height: 16),

              // ================= LANGUAGE =================
              DropdownButtonFormField<String>(
                value: language,
                decoration: const InputDecoration(
                  labelText: "Language",
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: "EN", child: Text("English")),
                  DropdownMenuItem(value: "HI", child: Text("Hindi")),
                  DropdownMenuItem(value: "ES", child: Text("Spanish")),
                  DropdownMenuItem(value: "OTHER", child: Text("Other")),
                ],
                onChanged: (v) => setState(() => language = v),
              ),

              const SizedBox(height: 16),

              // ================= DISCOVERABLE =================
              SwitchListTile(
                value: discoverable,
                onChanged: (v) => setState(() => discoverable = v),
                title: const Text("Show in Discover"),
                contentPadding: EdgeInsets.zero,
              ),

              // ================= NSFW =================
              SwitchListTile(
                value: nsfw,
                onChanged: (v) => setState(() => nsfw = v),
                title: const Text("NSFW Content"),
                contentPadding: EdgeInsets.zero,
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: saving ? null : _save,
                  child: saving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text("Save Changes"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}