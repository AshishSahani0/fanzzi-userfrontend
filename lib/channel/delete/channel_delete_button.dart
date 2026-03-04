// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:frontenduser/channel/delete/channel_delete_api.dart';

class ChannelDeleteButton extends StatefulWidget {
  final String channelId;

  const ChannelDeleteButton({
    super.key,
    required this.channelId,
  });

  @override
  State<ChannelDeleteButton> createState() =>
      _ChannelDeleteButtonState();
}

class _ChannelDeleteButtonState
    extends State<ChannelDeleteButton> {

  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      enabled: !_loading,
      leading: _loading
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.red,
              ),
            )
          : const Icon(
              Icons.delete_forever,
              color: Colors.red,
            ),
      title: const Text(
        "Delete Channel",
        style: TextStyle(color: Colors.red),
      ),
      onTap: _loading ? null : () => _handleDelete(context),
    );
  }

  Future<void> _handleDelete(BuildContext context) async {
    final confirmed = await _showConfirmDialog(context);

    if (confirmed != true) return;

    setState(() => _loading = true);

    try {
      await ChannelDeleteApi.deleteChannel(widget.channelId);

      if (!mounted) return;

      // Return result to previous screen
      Navigator.of(context).pop(true);

    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Delete failed: $e")),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<bool?> _showConfirmDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: !_loading,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Delete Channel"),
          content: const Text(
            "This will permanently delete this channel.\n\n"
            "All members, posts, and subscriptions will be removed.\n\n"
            "This action cannot be undone.",
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.of(ctx).pop(false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () =>
                  Navigator.of(ctx).pop(true),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }
}