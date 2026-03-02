import 'package:flutter/material.dart';

class ChannelGiftButton extends StatelessWidget {
  const ChannelGiftButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.card_giftcard, color: Colors.white),
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("🎁 Gifts Coming Soon")),
        );
      },
    );
  }
}
