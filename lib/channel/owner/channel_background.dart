import 'package:flutter/material.dart';

class ChannelBackground extends StatelessWidget {
  final Widget child;

  const ChannelBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      // ✅ Telegram-like adaptive background
      color: isDark
          ? const Color(0xFF0F0F0F) // Dark mode background
          : const Color(0xFFF4F4F5), // Light mode background

      child: child,
    );
  }
}
