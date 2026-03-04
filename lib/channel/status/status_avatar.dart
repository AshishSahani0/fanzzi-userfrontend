import 'package:flutter/material.dart';
import 'status_upload_controller.dart';

class StatusAvatar extends StatelessWidget {
  final String? imageUrl;
  final String fallbackText;
  final bool hasStatus;
  final bool isSeen; // 🔥 add seen support
  final double radius;
  final VoidCallback onTap;

  const StatusAvatar({
    super.key,
    required this.imageUrl,
    required this.fallbackText,
    required this.hasStatus,
    required this.onTap,
    this.radius = 22,
    this.isSeen = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: StatusUploadController.instance,
      builder: (_, __) {
        final uploading =
            StatusUploadController.instance.uploading;
        final progress =
            StatusUploadController.instance.progress;

        return GestureDetector(
          onTap: onTap,
          child: SizedBox(
            width: (radius + 10) * 2,
            height: (radius + 10) * 2,
            child: Stack(
              alignment: Alignment.center,
              children: [

                /// 🔥 Upload progress ring
                if (uploading)
                  SizedBox(
                    width: (radius + 8) * 2,
                    height: (radius + 8) * 2,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 4,
                      backgroundColor: Colors.grey.shade300,
                      valueColor:
                          const AlwaysStoppedAnimation(
                        Colors.blue,
                      ),
                    ),
                  )

                /// 🔥 Status ring
                else if (hasStatus)
                  Container(
                    width: (radius + 6) * 2,
                    height: (radius + 6) * 2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: isSeen
                          ? const LinearGradient(
                              colors: [
                                Colors.grey,
                                Colors.grey,
                              ],
                            )
                          : const LinearGradient(
                              colors: [
                                Color(0xFF3B82F6),
                                Color(0xFF60A5FA),
                                Color(0xFF93C5FD),
                              ],
                            ),
                    ),
                  ),

                /// 🔥 Avatar
                _avatar(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _avatar() {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey.shade200,
      backgroundImage:
          imageUrl != null && imageUrl!.isNotEmpty
              ? NetworkImage(imageUrl!)
              : null,
      child: (imageUrl == null || imageUrl!.isEmpty)
          ? Text(
              fallbackText.characters.first
                  .toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: radius * 0.9,
                color: Colors.black87,
              ),
            )
          : null,
    );
  }
}