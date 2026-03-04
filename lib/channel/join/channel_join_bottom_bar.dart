import 'package:flutter/material.dart';

class ChannelJoinBottomBar extends StatelessWidget {
  final VoidCallback onJoin;
  final VoidCallback onGift;
  final bool joined;
  final bool joining;
  final String joinText;

  const ChannelJoinBottomBar({
    super.key,
    required this.onJoin,
    required this.onGift,
    required this.joined,
    required this.joining,
    this.joinText = "Join Channel",
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            _GiftButton(onGift: onGift),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: joined || joining ? null : onJoin,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      joined ? Colors.green : Colors.blue,
                  padding: const EdgeInsets.symmetric(
                      vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: joining
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        joined ? "Joined" : joinText,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GiftButton extends StatelessWidget {
  final VoidCallback onGift;

  const _GiftButton({required this.onGift});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: const Icon(Icons.card_giftcard),
        onPressed: onGift,
      ),
    );
  }
}