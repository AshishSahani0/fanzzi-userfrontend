import 'package:flutter/material.dart';

class StatusAvatar extends StatelessWidget {
  final String? imageUrl;
  final String fallbackText;
  final bool hasStatus;
  final double radius;
  final VoidCallback onTap;

  const StatusAvatar({
    super.key,
    required this.imageUrl,
    required this.fallbackText,
    required this.hasStatus,
    required this.onTap,
    this.radius = 22,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        padding: hasStatus ? const EdgeInsets.all(3) : EdgeInsets.zero,
        decoration: hasStatus
            ? const BoxDecoration(
                shape: BoxShape.circle,

                /// ⭐ Instagram / WhatsApp style gradient ring
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF3B82F6),
                    Color(0xFF60A5FA),
                    Color(0xFF93C5FD),
                  ],
                ),
              )
            : null,

        child: Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),

          padding: const EdgeInsets.all(2),

          child: CircleAvatar(
            radius: radius,
            backgroundColor: Colors.grey.shade200,

            /// ⭐ Network image
            backgroundImage:
                imageUrl != null && imageUrl!.isNotEmpty
                    ? NetworkImage(imageUrl!)
                    : null,

            /// ⭐ Fallback text avatar
            child: (imageUrl == null || imageUrl!.isEmpty)
                ? Text(
                    fallbackText.characters.first.toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: radius * 0.9,
                      color: Colors.black87,
                    ),
                  )
                : null,
          ),
        ),
      ),
    );
  }
}