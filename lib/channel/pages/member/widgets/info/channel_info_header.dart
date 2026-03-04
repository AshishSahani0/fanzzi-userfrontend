import 'package:flutter/material.dart';
import '../../../../model/channel_model.dart';

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
    final isPaid = channel.type == "PAID";
    final isPrivate = channel.visibility == "PRIVATE";

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60),
      color: Colors.blue.shade700,
      child: Column(
        children: [
          CircleAvatar(
            radius: 45,
            backgroundImage: channel.profileImageUrl != null
                ? NetworkImage(channel.profileImageUrl!)
                : null,
            child: channel.profileImageUrl == null
                ? Text(
                    channel.name[0].toUpperCase(),
                    style: const TextStyle(fontSize: 30),
                  )
                : null,
          ),

          const SizedBox(height: 4),

          Text(
            channel.name,
            style: const TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 5),

          /// 🔥 TYPE + VISIBILITY ROW
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              /// 💰 TYPE BADGE
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isPaid
                      ? Colors.orange.shade600
                      : Colors.green.shade600,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isPaid
                      ? "PAID • ₹${channel.monthlyPrice ?? 0}/mo"
                      : "FREE",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(width: 5),

              /// 🔐 VISIBILITY BADGE
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isPrivate
                      ? Colors.red.shade500
                      : Colors.teal.shade600,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isPrivate ? "PRIVATE" : "PUBLIC",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 3),

          Text(
            "${_formatCount(channel.memberCount)} "
            "member${channel.memberCount == 1 ? '' : 's'}",
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}