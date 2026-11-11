import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

/// Microscopic pill-shaped eyebrow tag preceding major headings.
class EyebrowTag extends StatelessWidget {
  final String label;
  final bool center;

  const EyebrowTag({
    super.key,
    required this.label,
    this.center = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.glassFill,
        border: Border.all(color: AppColors.hairline, width: 1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 2.4,
            ),
          ),
        ],
      ),
    );
  }
}

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
        EyebrowTag(label: label),
        const SizedBox(height: 32),
        Text(
          title,
          style: TextStyle(
            fontSize: isMobile ? 38 : 56,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
            height: 1.05,
            letterSpacing: -1.8,
          ),
          textAlign: center ? TextAlign.center : TextAlign.left,
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 20),
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
