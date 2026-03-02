import 'package:flutter/material.dart';
import 'package:frontenduser/core/ui/theme/app_colors.dart';


class CameraButton extends StatelessWidget {
  final VoidCallback onTap;

  const CameraButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70,
        height: 70,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.accent,
        ),
        child: const Icon(Icons.camera_alt,
            size: 32, color: Colors.black),
      ),
    );
  }
}