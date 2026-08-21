import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class CalComEmbedImpl extends StatelessWidget {
  final String calLink;
  final double height;

  const CalComEmbedImpl({
    super.key,
    required this.calLink,
    this.height = 600,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.base,
        border: Border.all(color: AppColors.border, width: 1),
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.event_available_outlined,
            size: 40,
            color: AppColors.accent,
          ),
          const SizedBox(height: 16),
          Text(
            'Scheduling is available on the web version',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
