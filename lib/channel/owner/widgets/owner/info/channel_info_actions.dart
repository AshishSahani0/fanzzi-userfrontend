import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontenduser/channel/util/camera_util.dart';
import 'package:frontenduser/channel/owner/widgets/owner/info/channel_status_composer_page.dart';

class ChannelInfoActions extends StatelessWidget {
  final String channelId;

  const ChannelInfoActions({
    super.key,
    required this.channelId,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _ActionBtn(
          icon: Icons.wifi_tethering,
          text: "Live Stream",
          onTap: () {
            // TODO: live stream setup
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
          onTap: () => _showStatusPicker(context),
        ),
      ],
    );
  }

  // ----------------------------------
  // 📸 / 🎥 / 🖼 PICK SOURCE
  // ----------------------------------
  void _showStatusPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _sheetTile(
              icon: Icons.camera_alt,
              title: "Camera Photo",
              onTap: () async {
                Navigator.pop(context);

                final File? file =
                    await CameraUtil.cameraPhoto();
                if (file == null) return;

                _openComposer(context, file);
              },
            ),
            _sheetTile(
              icon: Icons.videocam,
              title: "Camera Video",
              onTap: () async {
                Navigator.pop(context);

                final File? file =
                    await CameraUtil.cameraVideo();
                if (file == null) return;

                _openComposer(context, file);
              },
            ),
            _sheetTile(
              icon: Icons.photo_library,
              title: "Gallery",
              onTap: () async {
                Navigator.pop(context);

                final File? file =
                    await CameraUtil.galleryPhoto();
                if (file == null) return;

                _openComposer(context, file);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _openComposer(BuildContext context, File file) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChannelStatusComposerPage(
          channelId: channelId,
          file: file,
        ),
      ),
    );
  }

  Widget _sheetTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
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
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        width: 110,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white),
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