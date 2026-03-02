import 'package:flutter/material.dart';
import 'package:frontenduser/channel/delete/channel_delete_api.dart';

class ChannelDeleteButton extends StatelessWidget {
  final String channelId;

  const ChannelDeleteButton({
    super.key,
    required this.channelId,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(
        Icons.delete_forever,
        color: Colors.red,
      ),
      title: const Text(
        "Delete Channel",
        style: TextStyle(color: Colors.red),
      ),
      onTap: () => _confirmDelete(context),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Channel"),
        content: const Text(
          "This will permanently delete the channel, including:\n"
          "• All members\n"
          "• All posts & media\n"
          "• All subscriptions\n\n"
          "This action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete Permanently"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await ChannelDeleteApi.deleteChannel(channelId);

      if (!context.mounted) return;

      Navigator.pop(context);       // close menu
      Navigator.pop(context, true); // exit info page

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("🗑️ Channel deleted")),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Delete failed: $e")),
      );
    }
  }
}