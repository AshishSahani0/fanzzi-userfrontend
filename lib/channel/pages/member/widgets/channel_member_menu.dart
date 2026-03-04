import 'package:flutter/material.dart';
import 'package:frontenduser/channel/membership/channel_membership_api.dart';
import 'package:frontenduser/channel/block/channel_block_api.dart';
import 'package:frontenduser/channel/model/channel_model.dart';
import 'package:frontenduser/channel/pages/member/widgets/report_channel_dialog.dart';

class ChannelMemberMenu extends StatelessWidget {
  final ChannelModel channel;

  const ChannelMemberMenu({super.key, required this.channel});

  // =========================================================
  // 🔴 Leave Channel
  // =========================================================
  Future<void> _leaveChannel(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Leave Channel?"),
        content: Text(
          "Are you sure you want to leave '${channel.name}'?",
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
            child: const Text("Leave"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await ChannelMembershipApi.leaveChannel(channel.id);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Left channel successfully")),
      );

      Navigator.pop(context, true); // notify parent
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Leave failed: $e")),
      );
    }
  }

  // =========================================================
  // 🚫 Block Channel
  // =========================================================
  Future<void> _blockChannel(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Block Channel?"),
        content: Text(
          "You will stop seeing '${channel.name}', leave it automatically, "
          "and it won’t appear in recommendations.",
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
      await ChannelBlockApi.blockChannel(channel.id);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("🚫 Channel blocked")),
      );

      Navigator.pop(context, true); // exit channel page
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Block failed: $e")),
      );
    }
  }

  // =========================================================
  // 🚨 Report Channel
  // =========================================================
  Future<void> _showReportDialog(BuildContext context) async {
    final result = await showDialog(
      context: context,
      builder: (_) => ReportChannelDialog(channelId: channel.id),
    );

    if (result == true && context.mounted) {
      Navigator.pop(context, true); // notify parent
    }
  }

  // =========================================================
  // 🧠 BUILD MENU
  // =========================================================
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.white),
      position: PopupMenuPosition.under,
      onSelected: (value) {
        switch (value) {
          case "leave":
            _leaveChannel(context);
            break;

          case "report":
            _showReportDialog(context);
            break;

          case "block":
            _blockChannel(context);
            break;

          case "mute":
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("🔕 Notifications muted")),
            );
            break;
        }
      },
      itemBuilder: (_) => [
        // 🚨 REPORT (members only, not owner)
        if (channel.member && !channel.owner)
          const PopupMenuItem(
            value: "report",
            child: Row(
              children: [
                Icon(Icons.flag_outlined),
                SizedBox(width: 12),
                Text("Report Channel"),
              ],
            ),
          ),

        // 🚫 BLOCK (not owner)
        if (!channel.owner)
          const PopupMenuItem(
            value: "block",
            child: Row(
              children: [
                Icon(Icons.block, color: Colors.red),
                SizedBox(width: 12),
                Text(
                  "Block Channel",
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),

        // 🔕 MUTE
        const PopupMenuItem(
          value: "mute",
          child: Row(
            children: [
              Icon(Icons.notifications_off_outlined),
              SizedBox(width: 12),
              Text("Mute Notifications"),
            ],
          ),
        ),

        // 🔴 LEAVE
        const PopupMenuItem(
          value: "leave",
          child: Row(
            children: [
              Icon(Icons.exit_to_app, color: Colors.red),
              SizedBox(width: 12),
              Text(
                "Leave Channel",
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
      ],
    );
  }
}