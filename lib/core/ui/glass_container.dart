import 'dart:ui';
import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blur;
  final EdgeInsets padding;
  final Color tintColor;

  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius = 22,
    this.blur = 18,
    this.padding = const EdgeInsets.all(8),

    /// ⭐ DEFAULT = BLUE GLASS
    this.tintColor = const Color(0xFF2196F3),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius:
          BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: blur,
          sigmaY: blur,
        ),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(borderRadius),

            /// 🔵 BLUE GLASS COLOR
            color: tintColor.withValues(alpha: 0.18),

            /// Subtle highlight border
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.35),
            ),

            boxShadow: [
              BoxShadow(
                blurRadius: 20,
                color: tintColor.withValues(alpha: 0.25),
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}