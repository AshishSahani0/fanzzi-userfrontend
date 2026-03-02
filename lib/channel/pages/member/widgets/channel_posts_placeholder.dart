import 'package:flutter/material.dart';

class ChannelPostsPlaceholder extends StatelessWidget {
  final bool joined;

  const ChannelPostsPlaceholder({super.key, required this.joined});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              joined ? Icons.campaign_outlined : Icons.lock_outline,
              size: 60,
              color: joined
                  ? theme.colorScheme.primary
                  : Colors.grey.shade500,
            ),
            const SizedBox(height: 20),
            Text(
              joined ? "No posts yet" : "You are not a member yet",
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              joined
                  ? "When the creator posts, it will appear here."
                  : "Join this channel to access posts.",
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}