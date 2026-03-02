import 'package:flutter/material.dart';
import 'package:frontenduser/channel/owner/widgets/owner/info/channel_status_viewer_page.dart';
import 'package:frontenduser/channel/owner/widgets/owner/info/status_avatar.dart';
import '../../../../model/channel_model.dart';

import 'channel_info_actions.dart';

class ChannelInfoHeader extends StatelessWidget {
  final ChannelModel channel;

  const ChannelInfoHeader({super.key, required this.channel});

  @override
  Widget build(BuildContext context) {
    final name = channel.name.isNotEmpty ? channel.name : "Channel";

    final visibility = (channel.visibility ?? "PUBLIC").toUpperCase();

    return SliverAppBar(
      expandedHeight: 300, // ✅ FIX OVERFLOW
      pinned: true,
      backgroundColor: Colors.blue.shade700,

      /* actions: const [
        Icon(Icons.edit),
        SizedBox(width: 12),
        Icon(Icons.more_vert),
        SizedBox(width: 8),
      ], */
      flexibleSpace: FlexibleSpaceBar(
        background: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              StatusAvatar(
                radius: 52,
                imageUrl: channel.profileImageUrl,
                fallbackText: channel.name[0],
                hasStatus: channel.hasActiveStatus,
                onTap: () {
                  if (channel.hasActiveStatus) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ChannelStatusViewerPage(channelId: channel.id),
                      ),
                    );
                  }
                },
              ),

              const SizedBox(height: 15),

              Text(
                name,
                style: const TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                visibility == "PUBLIC" ? "Public Channel" : "Private Channel",
                style: const TextStyle(fontSize: 14, color: Colors.white70),
              ),

              const SizedBox(height: 20),

              // ✅ Action Buttons Component
              ChannelInfoActions(channelId: channel.id),
            ],
          ),
        ),
      ),
    );
  }
}
