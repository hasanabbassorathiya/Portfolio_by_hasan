/// Empty state widget
/// Shows a modern empty state when there's no data
import 'package:flutter/material.dart';
import 'package:portfolio/shared/constants/colors.dart';
import 'package:portfolio/shared/constants/utils.dart';

class EmptyState extends StatelessWidget {
  final String title;
  final String? message;
  final IconData icon;
  final VoidCallback? onAction;
  final String? actionLabel;

  const EmptyState({
    super.key,
    required this.title,
    this.message,
    this.icon = Icons.inbox_outlined,
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSmall = MediaQuery.of(context).size.width < 700;

    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: isSmall ? double.infinity : 500),
        padding: EdgeInsets.all(isSmall ? 32 : 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with gradient background
            Container(
              width: isSmall ? 80 : 120,
              height: isSmall ? 80 : 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppUtils().appGradient,
              ),
              child: Icon(icon, size: isSmall ? 40 : 60, color: Colors.white),
            ),
            SizedBox(height: isSmall ? 24 : 32),
            // Title
            Text(
              title,
              style: TextStyle(
                fontSize: isSmall ? 24 : 32,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              SizedBox(height: isSmall ? 12 : 16),
              Text(
                message!,
                style: TextStyle(
                  fontSize: isSmall ? 14 : 16,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onAction != null && actionLabel != null) ...[
              SizedBox(height: isSmall ? 24 : 32),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmall ? 24 : 32,
                    vertical: isSmall ? 12 : 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ).copyWith(
                  backgroundColor: MaterialStateProperty.all<Color>(
                    AppColors.primaryColor,
                  ),
                ),
                child: Text(
                  actionLabel!,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isSmall ? 14 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
