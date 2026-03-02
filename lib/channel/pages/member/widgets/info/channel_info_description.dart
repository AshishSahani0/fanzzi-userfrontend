import 'package:flutter/material.dart';
import 'package:frontenduser/channel/model/channel_model.dart';

class ChannelInfoDescription extends StatelessWidget {
  final ChannelModel channel;

  const ChannelInfoDescription({
    super.key,
    required this.channel,
  });

  @override
  Widget build(BuildContext context) {
    if (channel.description?.isEmpty ?? true) {
      return const SizedBox(); // hide if no description
    }

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// 🔥 Title
          const Text(
            "Description",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 8),

          /// 📝 Description Text
          Text(
            channel.description ?? '',
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}