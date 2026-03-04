import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:frontenduser/channel/membership/channel_membership_api.dart';
import '../../../../model/channel_model.dart';

class ChannelInfoActions extends StatelessWidget {
  final ChannelModel channel;

  const ChannelInfoActions({super.key, required this.channel});

  // ✅ Action Button Widget
  Widget action(
    BuildContext context,
    IconData icon,
    String label, {
    Color color = Colors.blue,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 52,
              width: 52,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 8,
                    color: Colors.black.withOpacity(0.06),
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: color, size: 26),
            ),

            const SizedBox(height: 6),

            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // ✅ Leave Channel Function
  // =====================================================
  Future<void> leaveChannel(BuildContext context) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Leave Channel?"),
        content: Text("Are you sure you want to leave '${channel.name}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Leave"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      // ✅ Backend Call
      await ChannelMembershipApi.leaveChannel(channel.id);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Left channel successfully")),
      );

      // ✅ CLOSE ChannelInfoPage first
      Navigator.pop(context);

      // ✅ CLOSE ChannelMemberPage + return refresh signal
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Leave failed: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          action(
            context,
            Icons.volume_off,
            "Unmute",
            color: Colors.blue,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("🔕 Unmute coming soon")),
              );
            },
          ),

          action(
            context,
            Icons.card_giftcard,
            "Gift",
            color: Colors.purple,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("🎁 Gifts coming soon")),
              );
            },
          ),

          action(
            context,
            Icons.share,
            "Share",
            color: Colors.green,
            onTap: () {
              final link = channel.inviteLink;

              if (link == null || link.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Invite link not available ❌")),
                );
                return;
              }

              Share.share(
                "Join my channel on Fanzzi 💙\n$link",
                subject: channel.name,
              );
            },
          ),

          // ✅ Leave Button Working
          action(
            context,
            Icons.exit_to_app,
            "Leave",
            color: Colors.red,
            onTap: () => leaveChannel(context),
          ),
        ],
      ),
    );
  }
}
