import 'package:flutter/material.dart';
import 'channel_status_views_page.dart';

class ChannelStatusViewsButton extends StatelessWidget {

  final String channelId;
  final String statusId;
  final int viewCount;
  final bool isOwner;

  const ChannelStatusViewsButton({
    super.key,
    required this.channelId,
    required this.statusId,
    required this.viewCount,
    required this.isOwner,
  });

  void _openViewers(BuildContext context) {

    if (!isOwner) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: ChannelStatusViewsPage(
            channelId: channelId,
            statusId: statusId,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: () => _openViewers(context),
      child: Row(
        children: [

          const Icon(
            Icons.remove_red_eye,
            size: 18,
            color: Colors.white70,
          ),

          const SizedBox(width: 6),

          Text(
            "$viewCount",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),

        ],
      ),
    );
  }
}