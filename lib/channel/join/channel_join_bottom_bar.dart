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
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Gift Icon Always Visible
            Container(
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
            ),

            const SizedBox(width: 10),

            // Join → Joined Button
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: joined
                      ? Colors.green
                      : Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),

                // ✅ Disable click if joined
                onPressed: joined
                    ? null
                    : joining
                        ? () {}
                        : onJoin,

                child: Text(
                  joined
                      ? "✅ Joined"
                      : joining
                          ? "Joining..."
                          : joinText,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
