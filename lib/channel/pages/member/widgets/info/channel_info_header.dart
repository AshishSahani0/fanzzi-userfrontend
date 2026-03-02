import 'package:flutter/material.dart';
import '../../../../model/channel_model.dart';

class ChannelInfoHeader extends StatelessWidget {
  final ChannelModel channel;

  const ChannelInfoHeader({super.key, required this.channel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
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

          const SizedBox(height: 12),

          Text(
            channel.name,
            style: const TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          const Text(
            "2.2M subscribers", // later dynamic
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}
