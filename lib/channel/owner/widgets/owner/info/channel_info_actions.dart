import 'package:flutter/material.dart';
import 'package:frontenduser/channel/status/channel_status_camera_page.dart';

class ChannelInfoActions extends StatelessWidget {
  final String channelId;

  const ChannelInfoActions({
    super.key,
    required this.channelId,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceEvenly,
      children: [
        _ActionBtn(
          icon: Icons.wifi_tethering,
          text: "Live Stream",
          onTap: () {
            // TODO: Live stream
          },
        ),

        _ActionBtn(
          icon: Icons.volume_off,
          text: "Unmute",
          onTap: () {
            // TODO: mute/unmute
          },
        ),

        _ActionBtn(
          icon: Icons.add_circle_outline,
          text: "Add Story",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    ChannelStatusCameraPage(
                  channelId: channelId,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius:
          BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        width: 110,
        padding:
            const EdgeInsets.symmetric(
                vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white
              .withOpacity(0.15),
          borderRadius:
              BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon,
                color: Colors.white),
            const SizedBox(height: 6),
            Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}