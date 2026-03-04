import 'package:flutter/material.dart';
import 'package:frontenduser/channel/model/channel_model.dart';
import 'package:frontenduser/channel/pages/member/widgets/info/channel_info_page.dart';
import 'channel_member_menu.dart';

class ChannelMemberAppBar extends StatelessWidget
    implements PreferredSizeWidget {

  final ChannelModel channel;

  const ChannelMemberAppBar({
    super.key,
    required this.channel,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

 bool get _showSubscribeButton {
  return channel.type == "PAID" &&
      !channel.owner &&
      !channel.subscribed;
}

  String _formatCount(int count) {
    if (count >= 1000000) {
      return "${(count / 1000000).toStringAsFixed(1)}M";
    }
    if (count >= 1000) {
      return "${(count / 1000).toStringAsFixed(1)}K";
    }
    return "$count";
  }

  @override
  Widget build(BuildContext context) {

    final formattedCount = _formatCount(channel.memberCount);

    return AppBar(
      backgroundColor: Colors.blue.shade700,
      titleSpacing: 0,

      title: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChannelInfoPage(channel: channel),
            ),
          );
        },
        child: Row(
          children: [

            const SizedBox(width: 8),

            /// ⭐ Avatar
            CircleAvatar(
              radius: 18,
              backgroundImage: channel.profileImageUrl != null
                  ? NetworkImage(channel.profileImageUrl!)
                  : null,
              child: channel.profileImageUrl == null
                  ? Text(channel.name[0].toUpperCase())
                  : null,
            ),

            const SizedBox(width: 10),

            /// ⭐ Name + Member Count
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    channel.name,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      "$formattedCount member${channel.memberCount == 1 ? '' : 's'}",
                      key: ValueKey(channel.memberCount),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      actions: [

        /// 🔥 Subscribe Button
        if (_showSubscribeButton)
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () => _openSubscribeSheet(context),
              child: const Text(
                "Subscribe",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

        ChannelMemberMenu(channel: channel),
      ],
    );
  }

  void _openSubscribeSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text(
                "Subscribe to ${channel.name}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                "Unlock full content access",
                style: TextStyle(color: Colors.grey.shade600),
              ),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "₹${channel.monthlyPrice} / month",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Confirm"),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}