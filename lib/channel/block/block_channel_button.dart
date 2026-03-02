import 'package:flutter/material.dart';
import 'package:frontenduser/channel/block/channel_block_api.dart';


class BlockChannelButton extends StatelessWidget {
  final String channelId;
  final String channelName;
  final bool isOwner;
  final VoidCallback? onBlocked;

  const BlockChannelButton({
    super.key,
    required this.channelId,
    required this.channelName,
    this.isOwner = false,
    this.onBlocked,
  });

  Future<void> _block(BuildContext context) async {
    if (isOwner) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("You cannot block your own channel"),
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Block Channel?"),
        content: Text(
          "You will leave '$channelName' and stop seeing its content.",
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
            child: const Text("Block"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await ChannelBlockApi.blockChannel(channelId);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("🚫 Channel blocked")),
      );

      onBlocked?.call();
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Block failed: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
      ),
      onPressed: () => _block(context),
      icon: const Icon(Icons.block),
      label: const Text("Block Channel"),
    );
  }
}