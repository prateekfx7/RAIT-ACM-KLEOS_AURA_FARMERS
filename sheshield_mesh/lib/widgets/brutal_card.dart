import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class BrutalCard extends StatelessWidget {
  final Widget child;
  final double width;
  final double height;
  final Color backgroundColor;

  const BrutalCard({
    super.key,
    required this.child,
    this.width = 280,
    this.height = 580,
    this.backgroundColor = AppColors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(36),
        border: Border.all(color: AppColors.ink, width: 8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28), // 36 - 8 to fit inside border cleanly
        child: child,
      ),
    );
  }
}
