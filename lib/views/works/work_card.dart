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
  final String? playStoreUrl;
  final String? appStoreUrl;

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
    this.playStoreUrl,
    this.appStoreUrl,
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

        // Show popup dialog with work details and buttons
        _showWorkDialog(context);
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
                // Store buttons on card
                if ((widget.playStoreUrl != null && widget.playStoreUrl!.isNotEmpty) ||
                    (widget.appStoreUrl != null && widget.appStoreUrl!.isNotEmpty)) ...[
                  AppUtils().vSpace(size: DesignTokens.space12),
                  Row(
                    children: [
                      if (widget.playStoreUrl != null && widget.playStoreUrl!.isNotEmpty)
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              LinkUtils.launchUrl(
                                widget.playStoreUrl!,
                                linkType: 'play_store',
                                linkName: 'Play Store',
                              );
                            },
                            child: Image.network(
                              'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRSv479P9YVGLOLcKO-lyUEOUTzgY44actorw&s',
                              height: 40,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.android, color: Colors.black, size: 16),
                                        SizedBox(width: 4),
                                        Text('Play Store', style: TextStyle(color: Colors.black, fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      if (widget.playStoreUrl != null && widget.playStoreUrl!.isNotEmpty &&
                          widget.appStoreUrl != null && widget.appStoreUrl!.isNotEmpty)
                        SizedBox(width: DesignTokens.space8),
                      if (widget.appStoreUrl != null && widget.appStoreUrl!.isNotEmpty)
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              LinkUtils.launchUrl(
                                widget.appStoreUrl!,
                                linkType: 'app_store',
                                linkName: 'App Store',
                              );
                            },
                            child: Image.network(
                              'https://upload.wikimedia.org/wikipedia/commons/3/3c/Download_on_the_App_Store_Badge.svg',
                              height: 40,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.apple, color: Colors.black, size: 16),
                                        SizedBox(width: 4),
                                        Text('App Store', style: TextStyle(color: Colors.black, fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showWorkDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.borderRadius16),
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with image
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(DesignTokens.borderRadius16),
                    topRight: Radius.circular(DesignTokens.borderRadius16),
                  ),
                  child: widget.imageAsset.startsWith('http://') || widget.imageAsset.startsWith('https://')
                      ? Image.network(
                          widget.imageAsset,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 200,
                              color: AppColors.backgroundDark,
                              child: const Icon(Icons.image, size: 48),
                            );
                          },
                        )
                      : Image.asset(
                          widget.imageAsset,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 200,
                              color: AppColors.backgroundDark,
                              child: const Icon(Icons.image, size: 48),
                            );
                          },
                        ),
                ),
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(DesignTokens.space24),
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
                        ),
                        AppUtils().vSpace(size: DesignTokens.space12),
                        Text(
                          widget.description,
                          style: AppStyles.body(context: context),
                        ),
                        if (widget.tags.isNotEmpty) ...[
                          AppUtils().vSpace(size: DesignTokens.space16),
                          Wrap(
                            spacing: DesignTokens.space8,
                            runSpacing: DesignTokens.space8,
                            children: widget.tags.map((tag) {
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
                ),
                // Buttons
                Container(
                  padding: const EdgeInsets.all(DesignTokens.space16),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (widget.playStoreUrl != null && widget.playStoreUrl!.isNotEmpty)
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              LinkUtils.launchUrl(
                                widget.playStoreUrl!,
                                linkType: 'play_store',
                                linkName: 'Play Store',
                              );
                            },
                            child: Image.network(
                              'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRSv479P9YVGLOLcKO-lyUEOUTzgY44actorw&s',
                              height: 50,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.android, color: Colors.black),
                                        SizedBox(width: 8),
                                        Text('Play Store', style: TextStyle(color: Colors.black)),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      if (widget.playStoreUrl != null && widget.playStoreUrl!.isNotEmpty &&
                          widget.appStoreUrl != null && widget.appStoreUrl!.isNotEmpty)
                        SizedBox(width: DesignTokens.space12),
                      if (widget.appStoreUrl != null && widget.appStoreUrl!.isNotEmpty)
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              LinkUtils.launchUrl(
                                widget.appStoreUrl!,
                                linkType: 'app_store',
                                linkName: 'App Store',
                              );
                            },
                            child: Image.network(
                              'https://upload.wikimedia.org/wikipedia/commons/3/3c/Download_on_the_App_Store_Badge.svg',
                              height: 50,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.apple, color: Colors.black),
                                        SizedBox(width: 8),
                                        Text('App Store', style: TextStyle(color: Colors.black)),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      if (widget.projectUrl != null &&
                          widget.projectUrl!.isNotEmpty &&
                          !widget.projectUrl!.startsWith('YOUR_')) ...[
                        if ((widget.playStoreUrl != null && widget.playStoreUrl!.isNotEmpty) ||
                            (widget.appStoreUrl != null && widget.appStoreUrl!.isNotEmpty))
                          SizedBox(width: DesignTokens.space12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              LinkUtils.launchUrl(
                                widget.projectUrl!,
                                linkType: 'work_project',
                                linkName: widget.title,
                              );
                            },
                            icon: const Icon(Icons.open_in_new),
                            label: const Text('View Project'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                      SizedBox(width: DesignTokens.space12),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          context.go('/works/${widget.workId}');
                        },
                        child: const Text('View Details'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
