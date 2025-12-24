import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:portfolio/shared/utils/link_utils.dart';
import 'package:portfolio/shared/widgets/modern_card.dart';
import 'package:portfolio/shared/constants/design_tokens.dart';
import 'package:portfolio/shared/constants/textstyles.dart';
import 'package:portfolio/shared/constants/colors.dart';
import 'package:portfolio/shared/constants/utils.dart';
import 'package:portfolio/core/services/analytics_service.dart';

class WorkCard extends StatefulWidget {
  final String imageAsset;
  final String title;
  final String description;
  final List<String> tags;
  final String? projectUrl;
  final String category;
  final String workId;
  final String? appIconUrl;

  const WorkCard({
    super.key,
    required this.imageAsset,
    required this.title,
    required this.description,
    required this.tags,
    this.projectUrl,
    required this.category,
    required this.workId,
    this.appIconUrl,
  });

  @override
  State<WorkCard> createState() => _WorkCardState();
}

class _WorkCardState extends State<WorkCard> {
  @override
  Widget build(BuildContext context) {
    return ModernCard(
      onTap: () {
        // Track work card click
        AnalyticsService.trackEvent(
          eventName: 'work_card_clicked',
          eventData: {
            'work_id': widget.workId,
            'work_title': widget.title,
            'category': widget.category,
          },
        );

        // Navigate to detail page if available, otherwise open URL
        if (widget.projectUrl != null &&
            widget.projectUrl!.isNotEmpty &&
            !widget.projectUrl!.startsWith('YOUR_')) {
          LinkUtils.launchUrl(
            widget.projectUrl!,
            linkType: 'work_project',
            linkName: widget.title,
          );
        } else {
          context.go('/works/${widget.workId}');
        }
      },
      showGradientBorder: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(DesignTokens.borderRadius8),
                child: widget.imageAsset.startsWith('http://') || widget.imageAsset.startsWith('https://')
                    ? Image.network(
                        widget.imageAsset,
                        fit: BoxFit.cover,
                        height: 200.0,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            color: AppColors.backgroundDark,
                            child: const Icon(Icons.image, size: 48),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 200,
                            color: AppColors.backgroundDark,
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
                      )
                    : Image.asset(
                        widget.imageAsset,
                        fit: BoxFit.cover,
                        height: 200.0,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            color: AppColors.backgroundDark,
                            child: const Icon(Icons.image, size: 48),
                          );
                        },
                      ),
              ),
              if (widget.appIconUrl != null && widget.appIconUrl!.isNotEmpty)
                Positioned(
                  bottom: DesignTokens.space12,
                  right: DesignTokens.space12,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        widget.appIconUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppColors.backgroundDark,
                            child: const Icon(Icons.apps, size: 24, color: Colors.white),
                          );
                        },
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(DesignTokens.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.category.toUpperCase(),
                  style: AppStyles.body(
                    fontSize: DesignTokens.fontSize12,
                    color: AppColors.textSecondary,
                    context: context,
                  ),
                ),
                AppUtils().vSpace(size: DesignTokens.space8),
                Text(
                  widget.title,
                  style: AppStyles.titleLarge(context: context),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                AppUtils().vSpace(size: DesignTokens.space8),
                Text(
                  widget.description,
                  style: AppStyles.body(context: context),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (widget.tags.isNotEmpty) ...[
                  AppUtils().vSpace(size: DesignTokens.space12),
                  Wrap(
                    spacing: DesignTokens.space8,
                    runSpacing: DesignTokens.space8,
                    children:
                        widget.tags.map((tag) {
                          return Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: DesignTokens.space12,
                              vertical: DesignTokens.space4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(
                                DesignTokens.borderRadius4,
                              ),
                            ),
                            child: Text(
                              tag,
                              style: AppStyles.body(
                                fontSize: DesignTokens.fontSize12,
                                color: AppColors.primary,
                                context: context,
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
