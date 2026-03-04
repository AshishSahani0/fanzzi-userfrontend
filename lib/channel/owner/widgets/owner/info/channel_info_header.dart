import 'package:flutter/material.dart';
import 'package:frontenduser/channel/status/channel_status_viewer_page.dart';
import 'package:frontenduser/channel/status/status_avatar.dart';
import '../../../../model/channel_model.dart';

import 'channel_info_actions.dart';

class ChannelInfoHeader extends StatelessWidget {
  final ChannelModel channel;

  const ChannelInfoHeader({super.key, required this.channel});

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
    final name = channel.name.isNotEmpty ? channel.name : "Channel";

    final visibility = (channel.visibility ?? "PUBLIC").toUpperCase();
    final type = (channel.type ?? "FREE").toUpperCase();
    final isPaid = type == "PAID";

    return SliverAppBar(
      expandedHeight: 320, // ✅ FIX OVERFLOW
      pinned: true,
      backgroundColor: Colors.blue.shade700,

  
      flexibleSpace: FlexibleSpaceBar(
        background: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 8),

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

              const SizedBox(height: 5),

              Text(
                name,
                style: const TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 2),

              Text(
              isPaid
                  ? "Paid Channel • ₹${channel.monthlyPrice ?? 0}/month"
                  : "Free Channel",
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 2),

              Text(
                visibility == "PUBLIC" ? "Public Channel" : "Private Channel",
                style: const TextStyle(fontSize: 14, color: Colors.white70),
              ),

              Text(
                "${_formatCount(channel.memberCount)} "
                "member${channel.memberCount == 1 ? '' : 's'}",
                style: const TextStyle(fontSize: 14, color: Colors.white70),
              ),
              const SizedBox(height: 7),
              // ✅ Action Buttons Component
              ChannelInfoActions(channelId: channel.id),
            ],
          ),
        ),
      ),
    );
  }
}
