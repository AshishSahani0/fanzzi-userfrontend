import 'package:flutter/material.dart';
import '../model/channel_subscriber_model.dart';

class SubscriberCard extends StatelessWidget {
  final ChannelSubscriberModel subscriber;

  const SubscriberCard({
    super.key,
    required this.subscriber,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [

          /// Avatar
          CircleAvatar(
            radius: 30,
            backgroundImage: subscriber.profileImageUrl != null
                ? NetworkImage(subscriber.profileImageUrl!)
                : null,
            child: subscriber.profileImageUrl == null
                ? Text(
                    subscriber.userName[0].toUpperCase(),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold),
                  )
                : null,
          ),

          const SizedBox(height: 6),

          /// Username
          Text(
            subscriber.userName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}