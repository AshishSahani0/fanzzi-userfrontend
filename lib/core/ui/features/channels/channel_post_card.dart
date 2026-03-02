import 'package:flutter/material.dart';

class ChannelPostCard extends StatelessWidget {
  const ChannelPostCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Text("Channel Announcement 🚀"),
      ),
    );
  }
}