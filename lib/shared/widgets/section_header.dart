import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class SectionHeader extends StatelessWidget {
  final String label;
  final String title;
  final String? subtitle;
  final bool center;
  final CrossAxisAlignment crossAxisAlignment;

  const SectionHeader({
    super.key,
    required this.label,
    required this.title,
    this.subtitle,
    this.center = false,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final isMobile = w < 600;

    return Column(
      crossAxisAlignment: center ? CrossAxisAlignment.center : crossAxisAlignment,
      children: [
        Row(
          mainAxisSize: center ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: center ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            Container(width: 32, height: 2, color: AppColors.accent),
            const SizedBox(width: 16),
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.accent,
                letterSpacing: 3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),
        Text(
          title,
          style: TextStyle(
            fontSize: isMobile ? 36 : 52,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
            height: 1.1,
            letterSpacing: -1.5,
          ),
          textAlign: center ? TextAlign.center : TextAlign.left,
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 16),
          Text(
            subtitle!,
            style: TextStyle(
              fontSize: isMobile ? 15 : 17,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
            textAlign: center ? TextAlign.center : TextAlign.left,
          ),
        ],
      ],
    );
  }
}
