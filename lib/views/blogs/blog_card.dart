import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:portfolio/shared/constants/textstyles.dart';
import 'package:portfolio/shared/constants/colors.dart';
import 'package:portfolio/shared/widgets/modern_card.dart';
import 'package:portfolio/shared/constants/design_tokens.dart';
import 'package:portfolio/shared/constants/utils.dart';
import 'package:portfolio/core/services/analytics_service.dart';

class BlogCard extends StatefulWidget {
  final String imageAsset;
  final String date;
  final String title;
  final String blogId;

  const BlogCard({
    super.key,
    required this.imageAsset,
    required this.date,
    required this.title,
    required this.blogId,
  });

  @override
  _BlogCardState createState() => _BlogCardState();
}

class _BlogCardState extends State<BlogCard> {
  @override
  Widget build(BuildContext context) {
    return ModernCard(
      onTap: () {
        // Track blog card click
        AnalyticsService.trackEvent(
          eventName: 'blog_card_clicked',
          eventData: {
            'blog_id': widget.blogId,
            'blog_title': widget.title,
          },
        );
        context.go('/blogs/${widget.blogId}');
      },
      showGradientBorder: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(DesignTokens.borderRadius8),
            child: AspectRatio(
              aspectRatio: 16 / 10,
              child: Image.asset(
                widget.imageAsset,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.backgroundDark,
                    child: const Icon(Icons.image, size: 48),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(DesignTokens.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.date,
                  style: AppStyles.body(
                    fontSize: DesignTokens.fontSize12,
                    color: AppColors.textSecondary,
                    context: context,
                  ),
                ),
                AppUtils().vSpace(size: DesignTokens.space8),
                Text(
                  widget.title,
                  style: AppStyles.titleMedium(context: context),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
