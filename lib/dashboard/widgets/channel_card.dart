import 'package:flutter/material.dart';
import 'package:frontenduser/channel/model/channel_model.dart';
import 'package:frontenduser/channel/owner/widgets/owner/info/channel_status_viewer_page.dart';

class ChannelCard extends StatelessWidget {
  final ChannelModel channel;
  final VoidCallback? onTap;
  final bool showChevron;
  final String? subtitle;

  const ChannelCard({
    super.key,
    required this.channel,
    this.onTap,
    this.showChevron = true,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        child: Row(
          children: [
            _buildAvatar(context),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    channel.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle ?? "Tap to open channel",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            if (showChevron) ...[
              const SizedBox(width: 6),
              const Icon(
                Icons.chevron_right_rounded,
                color: Colors.grey,
                size: 20,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // =====================================================
  // 🖼 AVATAR
  // =====================================================

  Widget _buildAvatar(BuildContext context) {
    final imageUrl = channel.profileImageUrl;
    final fallbackLetter =
        channel.name.isNotEmpty ? channel.name[0].toUpperCase() : "?";

    return GestureDetector(
      onTap: () {
        if (channel.hasActiveStatus) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  ChannelStatusViewerPage(channelId: channel.id),
            ),
          );
        } else {
          onTap?.call();
        }
      },
      child: Stack(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: channel.hasActiveStatus
                  ? const LinearGradient(
                      colors: [
                        Color(0xFF2D7CF6),
                        Color(0xFF5A9BFF),
                      ],
                    )
                  : null,
            ),
            padding: const EdgeInsets.all(2),
            child: CircleAvatar(
              backgroundColor: Colors.grey.shade200,
              child: ClipOval(
                child: (imageUrl != null && imageUrl.isNotEmpty)
                    ? Image.network(
                        imageUrl,
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                        loadingBuilder:
                            (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          );
                        },
                        errorBuilder: (_, __, ___) {
                          return _fallbackAvatar(fallbackLetter);
                        },
                      )
                    : _fallbackAvatar(fallbackLetter),
              ),
            ),
          ),

          // Status dot indicator
          if (channel.hasActiveStatus)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _fallbackAvatar(String letter) {
    return Center(
      child: Text(
        letter,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    );
  }
}