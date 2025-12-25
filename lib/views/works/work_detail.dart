import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:portfolio/models/work/work_model.dart' hide WorkRepository;
import 'package:portfolio/core/repositories/work_repository.dart';
import 'package:portfolio/shared/constants/colors.dart';
import 'package:portfolio/shared/constants/design_tokens.dart';
import 'package:portfolio/shared/constants/textstyles.dart';
import 'package:portfolio/shared/constants/utils.dart';
import 'package:portfolio/shared/utils/responsive.dart';
import 'package:portfolio/shared/widgets/modern_button.dart';
import 'package:portfolio/shared/widgets/modern_card.dart';
import 'package:portfolio/shared/widgets/smooth_scroll_wrapper.dart';
import 'package:portfolio/core/services/analytics_service.dart';
import 'package:portfolio/shared/utils/link_utils.dart';

/// Work detail page
/// Displays full project details with case study information
/// Inspired by modern portfolio work detail layouts
class WorkDetail extends StatefulWidget {
  final String workId;

  const WorkDetail({super.key, required this.workId});

  @override
  State<WorkDetail> createState() => _WorkDetailState();
}

class _WorkDetailState extends State<WorkDetail>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  WorkModel? _work;
  final ScrollController _scrollController = ScrollController();
  final WorkRepository _workRepository = WorkRepository();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWork();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _controller.forward();
  }

  Future<void> _loadWork() async {
    try {
      final work = await _workRepository.getWorkById(widget.workId);
      if (work != null) {
        setState(() {
          _work = work;
          _isLoading = false;
        });
        
        // Track work view
        AnalyticsService.trackWorkView(work.id);
        AnalyticsService.trackPageView(
          pagePath: '/works/${work.id}',
          pageTitle: work.title,
        );
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_work == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Work not found'),
              AppUtils().vSpace(size: DesignTokens.space16),
              ModernButton(
                title: 'Back to Works',
                onTap: () => context.go('/works'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SmoothScrollWrapper(
          controller: _scrollController,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeroSection(context),
              // Show image carousel right after hero if images exist
              if (_work!.images != null && _work!.images!.isNotEmpty) ...[
                Padding(
                  padding: Responsive.padding(context),
                  child: _buildGallery(context),
                ),
              ],
              Padding(
                padding: Responsive.padding(context),
                child: ResponsiveBuilder(
                  mobile: _buildMobileLayout(context),
                  tablet: _buildTabletLayout(context),
                  desktop: _buildDesktopLayout(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Hero section with project image
  Widget _buildHeroSection(BuildContext context) {
    return AnimatedSection(
      delay: Duration.zero,
      child: Container(
        width: double.infinity,
        height: Responsive.value<double>(
          context: context,
          mobile: 350,
          tablet: 450,
          desktop: 600,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primaryColor.withOpacity(0.8),
              AppColors.primaryColor.withOpacity(0.4),
            ],
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _work!.imageAsset.startsWith('http://') || _work!.imageAsset.startsWith('https://')
                ? Image.network(
                    _work!.imageAsset,
                    fit: BoxFit.fill,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.backgroundDark,
                        child: const Icon(Icons.image, size: 64, color: Colors.white),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
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
                    _work!.imageAsset,
                    fit: BoxFit.fill,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.backgroundDark,
                        child: const Icon(Icons.image, size: 64, color: Colors.white),
                      );
                    },
                  ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.2),
                    Colors.black.withOpacity(0.6),
                  ],
                ),
              ),
            ),
            Positioned(
              top: Responsive.value<double>(
                context: context,
                mobile: 40,
                tablet: 60,
                desktop: 80,
              ),
              left: Responsive.horizontalPadding(context),
              right: Responsive.horizontalPadding(context),
              child: Row(
                children: [
                  ModernButton(
                    title: '',
                    icon: Icons.arrow_back,
                    variant: ButtonVariant.outline,
                    onTap: () => context.go('/works'),
                    padding: const EdgeInsets.all(DesignTokens.space12),
                  ),
                  const Spacer(),
                  if (_work!.projectUrl != null &&
                      _work!.projectUrl!.isNotEmpty &&
                      !_work!.projectUrl!.startsWith('YOUR_'))
                    ModernButton(
                      title: 'View Project',
                      icon: Icons.open_in_new,
                      variant: ButtonVariant.primary,
                      onTap: () {
                        // Launch URL
                      },
                    ),
                ],
              ),
            ),
            Positioned(
              bottom: Responsive.value<double>(
                context: context,
                mobile: 40,
                tablet: 60,
                desktop: 80,
              ),
              left: Responsive.horizontalPadding(context),
              right: Responsive.horizontalPadding(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (_work!.appIconUrl != null && _work!.appIconUrl!.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(right: DesignTokens.space16),
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withOpacity(0.3)),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              _work!.appIconUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.white.withOpacity(0.2),
                                  child: const Icon(Icons.apps, color: Colors.white),
                                );
                              },
                            ),
                          ),
                        ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: DesignTokens.space12,
                                vertical: DesignTokens.space6,
                              ),
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(
                                  DesignTokens.borderRadius4,
                                ),
                              ),
                              child: Text(
                                _work!.category.toUpperCase(),
                                style: AppStyles.body(
                                  fontSize: DesignTokens.fontSize12,
                                  color: Colors.white,
                                  context: context,
                                ),
                              ),
                            ),
                            AppUtils().vSpace(size: DesignTokens.space16),
                            Text(
                              _work!.title,
                              style: AppStyles.heading(
                                fontSize: Responsive.fontSize(
                                  context,
                                  DesignTokens.fontSize32,
                                ),
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                context: context,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            AppUtils().vSpace(size: DesignTokens.space12),
                            Text(
                              _work!.description,
                              style: AppStyles.body(
                                fontSize: DesignTokens.fontSize16,
                                color: Colors.white70,
                                context: context,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if ((_work!.playStoreUrl != null && _work!.playStoreUrl!.isNotEmpty) ||
                      (_work!.appStoreUrl != null && _work!.appStoreUrl!.isNotEmpty))
                    Padding(
                      padding: const EdgeInsets.only(top: DesignTokens.space16),
                      child: Row(
                        children: [
                          if (_work!.playStoreUrl != null && _work!.playStoreUrl!.isNotEmpty)
                            InkWell(
                              onTap: () {
                                LinkUtils.launchUrl(
                                  _work!.playStoreUrl!,
                                  linkType: 'play_store',
                                  linkName: 'Play Store',
                                );
                              },
                              child: Image.network(
                                'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRSv479P9YVGLOLcKO-lyUEOUTzgY44actorw&s',
                                height: 60,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 60,
                                    width: 180,
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
                          if (_work!.playStoreUrl != null && _work!.playStoreUrl!.isNotEmpty &&
                              _work!.appStoreUrl != null && _work!.appStoreUrl!.isNotEmpty)
                            AppUtils().hSpace(size: DesignTokens.space12),
                          if (_work!.appStoreUrl != null && _work!.appStoreUrl!.isNotEmpty)
                            InkWell(
                              onTap: () {
                                LinkUtils.launchUrl(
                                  _work!.appStoreUrl!,
                                  linkType: 'app_store',
                                  linkName: 'App Store',
                                );
                              },
                              child: Image.network(
                                'https://upload.wikimedia.org/wikipedia/commons/3/3c/Download_on_the_App_Store_Badge.svg',
                                height: 60,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 60,
                                    width: 180,
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
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppUtils().vSpace(size: DesignTokens.space32),
        _buildProjectOverview(context),
        AppUtils().vSpace(size: DesignTokens.space32),
        _buildDescription(context),
        if (_work!.challenge != null) ...[
          AppUtils().vSpace(size: DesignTokens.space32),
          _buildChallenge(context),
        ],
        if (_work!.solution != null) ...[
          AppUtils().vSpace(size: DesignTokens.space32),
          _buildSolution(context),
        ],
        AppUtils().vSpace(size: DesignTokens.space32),
        _buildTechnologies(context),
        AppUtils().vSpace(size: DesignTokens.space32),
        _buildTags(context),
        AppUtils().vSpace(size: DesignTokens.space48),
        _buildRelatedWorks(context),
        AppUtils().vSpace(size: DesignTokens.space48),
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: Responsive.maxContentWidth(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppUtils().vSpace(size: DesignTokens.space40),
          _buildProjectOverview(context),
          AppUtils().vSpace(size: DesignTokens.space40),
          _buildDescription(context),
          if (_work!.challenge != null) ...[
            AppUtils().vSpace(size: DesignTokens.space40),
            _buildChallenge(context),
          ],
          if (_work!.solution != null) ...[
            AppUtils().vSpace(size: DesignTokens.space40),
            _buildSolution(context),
          ],
          AppUtils().vSpace(size: DesignTokens.space40),
          _buildTechnologies(context),
          AppUtils().vSpace(size: DesignTokens.space40),
          _buildTags(context),
          AppUtils().vSpace(size: DesignTokens.space56),
          _buildRelatedWorks(context),
          AppUtils().vSpace(size: DesignTokens.space56),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: Responsive.maxContentWidth(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppUtils().vSpace(size: DesignTokens.space48),
            _buildProjectOverview(context),
            AppUtils().vSpace(size: DesignTokens.space48),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDescription(context),
                      if (_work!.challenge != null) ...[
                        AppUtils().vSpace(size: DesignTokens.space48),
                        _buildChallenge(context),
                      ],
                      if (_work!.solution != null) ...[
                        AppUtils().vSpace(size: DesignTokens.space48),
                        _buildSolution(context),
                      ],
                    ],
                  ),
                ),
                AppUtils().hSpace(size: DesignTokens.space48),
                SizedBox(
                  width: 300,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProjectInfo(context),
                      AppUtils().vSpace(size: DesignTokens.space32),
                      _buildTechnologies(context),
                    ],
                  ),
                ),
              ],
            ),
            AppUtils().vSpace(size: DesignTokens.space48),
            _buildTags(context),
            AppUtils().vSpace(size: DesignTokens.space64),
            _buildRelatedWorks(context),
            AppUtils().vSpace(size: DesignTokens.space64),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectOverview(BuildContext context) {
    return AnimatedSection(
      delay: const Duration(milliseconds: 100),
      child: ModernCard(
        child: Wrap(
          spacing: DesignTokens.space32,
          runSpacing: DesignTokens.space24,
          children: [
            if (_work!.client != null)
              _buildInfoItem(context, 'Client', _work!.client!, Icons.business),
            if (_work!.year != null)
              _buildInfoItem(
                context,
                'Year',
                _work!.year!,
                Icons.calendar_today,
              ),
            if (_work!.role != null)
              _buildInfoItem(context, 'Role', _work!.role!, Icons.person),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectInfo(BuildContext context) {
    return AnimatedSection(
      delay: const Duration(milliseconds: 150),
      child: ModernCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Project Info', style: AppStyles.titleSmall(context: context)),
            AppUtils().vSpace(size: DesignTokens.space16),
            if (_work!.client != null)
              _buildInfoRow(context, 'Client', _work!.client!, Icons.business),
            if (_work!.year != null)
              _buildInfoRow(
                context,
                'Year',
                _work!.year!,
                Icons.calendar_today,
              ),
            if (_work!.role != null)
              _buildInfoRow(context, 'Role', _work!.role!, Icons.person),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: DesignTokens.iconSize20, color: AppColors.primary),
            AppUtils().hSpace(size: DesignTokens.space8),
            Text(
              label,
              style: AppStyles.body(
                fontSize: DesignTokens.fontSize12,
                color: AppColors.textSecondary,
                context: context,
              ),
            ),
          ],
        ),
        AppUtils().vSpace(size: DesignTokens.space4),
        Text(
          value,
          style: AppStyles.body(fontWeight: FontWeight.bold, context: context),
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: DesignTokens.space12),
      child: Row(
        children: [
          Icon(icon, size: DesignTokens.iconSize18, color: AppColors.primary),
          AppUtils().hSpace(size: DesignTokens.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppStyles.body(
                    fontSize: DesignTokens.fontSize12,
                    color: AppColors.textSecondary,
                    context: context,
                  ),
                ),
                Text(
                  value,
                  style: AppStyles.body(
                    fontWeight: FontWeight.bold,
                    context: context,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(BuildContext context) {
    return AnimatedSection(
      delay: const Duration(milliseconds: 200),
      child: ModernCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Project Overview',
              style: AppStyles.titleLarge(context: context),
            ),
            AppUtils().vSpace(size: DesignTokens.space16),
            Text(
              _work!.description,
              style: AppStyles.bodyLarge(context: context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChallenge(BuildContext context) {
    return AnimatedSection(
      delay: const Duration(milliseconds: 300),
      child: ModernCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(DesignTokens.space8),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(
                      DesignTokens.borderRadius8,
                    ),
                  ),
                  child: Icon(
                    Icons.lightbulb_outline,
                    color: Colors.white,
                    size: DesignTokens.iconSize24,
                  ),
                ),
                AppUtils().hSpace(size: DesignTokens.space12),
                Text(
                  'Challenge',
                  style: AppStyles.titleLarge(context: context),
                ),
              ],
            ),
            AppUtils().vSpace(size: DesignTokens.space16),
            Text(
              _work!.challenge!,
              style: AppStyles.bodyLarge(context: context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSolution(BuildContext context) {
    return AnimatedSection(
      delay: const Duration(milliseconds: 400),
      child: ModernCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(DesignTokens.space8),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(
                      DesignTokens.borderRadius8,
                    ),
                  ),
                  child: Icon(
                    Icons.check_circle_outline,
                    color: Colors.white,
                    size: DesignTokens.iconSize24,
                  ),
                ),
                AppUtils().hSpace(size: DesignTokens.space12),
                Text('Solution', style: AppStyles.titleLarge(context: context)),
              ],
            ),
            AppUtils().vSpace(size: DesignTokens.space16),
            Text(
              _work!.solution!,
              style: AppStyles.bodyLarge(context: context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTechnologies(BuildContext context) {
    if (_work!.technologies == null || _work!.technologies!.isEmpty) {
      return const SizedBox.shrink();
    }

    return AnimatedSection(
      delay: const Duration(milliseconds: 500),
      child: ModernCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Technologies Used',
              style: AppStyles.titleSmall(context: context),
            ),
            AppUtils().vSpace(size: DesignTokens.space16),
            Wrap(
              spacing: DesignTokens.space12,
              runSpacing: DesignTokens.space12,
              children:
                  _work!.technologies!.map((tech) {
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: DesignTokens.space16,
                        vertical: DesignTokens.space8,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(
                          DesignTokens.borderRadius8,
                        ),
                      ),
                      child: Text(
                        tech,
                        style: AppStyles.body(
                          color: Colors.white,
                          context: context,
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTags(BuildContext context) {
    if (_work!.tags.isEmpty) return const SizedBox.shrink();

    return AnimatedSection(
      delay: const Duration(milliseconds: 600),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tags', style: AppStyles.subheading(context: context)),
          AppUtils().vSpace(size: DesignTokens.space16),
          Wrap(
            spacing: DesignTokens.space12,
            runSpacing: DesignTokens.space12,
            children:
                _work!.tags.map((tag) {
                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: DesignTokens.space16,
                      vertical: DesignTokens.space8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(
                        DesignTokens.borderRadius8,
                      ),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      tag,
                      style: AppStyles.body(
                        color: AppColors.primary,
                        context: context,
                      ),
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildGallery(BuildContext context) {
    if (_work!.images == null || _work!.images!.isEmpty) {
      return const SizedBox.shrink();
    }

    return AnimatedSection(
      delay: const Duration(milliseconds: 700),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Project Gallery',
            style: AppStyles.heading(
              fontSize: Responsive.fontSize(context, DesignTokens.fontSize32),
              fontWeight: FontWeight.bold,
              context: context,
            ),
          ),
          AppUtils().vSpace(size: DesignTokens.space24),
          _ImageCarousel(images: _work!.images!),
        ],
      ),
    );
  }

  Widget _buildRelatedWorks(BuildContext context) {
    // Related works will be loaded asynchronously
    return FutureBuilder<List<WorkModel>>(
      future: _workRepository.getAllWorks(limit: 4),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }
        
        final relatedWorks = snapshot.data!
            .where((work) => work.id != _work!.id)
            .take(3)
            .toList();
        
        if (relatedWorks.isEmpty) return const SizedBox.shrink();

        return AnimatedSection(
          delay: const Duration(milliseconds: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Related Projects',
                style: AppStyles.heading(
                  fontSize: Responsive.fontSize(context, DesignTokens.fontSize32),
                  fontWeight: FontWeight.bold,
                  context: context,
                ),
              ),
              AppUtils().vSpace(size: DesignTokens.space24),
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = Responsive.gridColumnCount(context);
                  final gap = Responsive.gridGap(context);
                  final itemWidth =
                      (constraints.maxWidth - (columns - 1) * gap) / columns;

                  return Wrap(
                    spacing: gap,
                    runSpacing: gap,
                    children:
                        relatedWorks.map((work) {
                          return SizedBox(
                            width: itemWidth,
                            child: _buildWorkCard(work),
                          );
                        }).toList(),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWorkCard(WorkModel work) {
    return ModernCard(
      onTap: () => context.go('/works/${work.id}'),
      showGradientBorder: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(DesignTokens.borderRadius8),
            child: Image.asset(
              work.imageAsset,
              fit: BoxFit.cover,
              height: 200,
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
          AppUtils().vSpace(size: DesignTokens.space16),
          Text(
            work.category.toUpperCase(),
            style: AppStyles.body(
              fontSize: DesignTokens.fontSize12,
              color: AppColors.textSecondary,
              context: null,
            ),
          ),
          AppUtils().vSpace(size: DesignTokens.space8),
          Text(
            work.title,
            style: AppStyles.titleMedium(context: null),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Image carousel widget for displaying multiple images
class _ImageCarousel extends StatefulWidget {
  final List<String> images;

  const _ImageCarousel({required this.images});

  @override
  State<_ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<_ImageCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 400,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: widget.images.length,
            itemBuilder: (context, index) {
              final imageUrl = widget.images[index];
              final isNetworkImage = imageUrl.startsWith('http://') || imageUrl.startsWith('https://');
              
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: DesignTokens.space8),
                child: ModernCard(
                  padding: EdgeInsets.zero,
                  showGradientBorder: true,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(DesignTokens.borderRadius12),
                    child: isNetworkImage
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 400,
                                color: AppColors.backgroundDark,
                                child: const Icon(Icons.image, size: 48),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                height: 400,
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
                            imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 400,
                                color: AppColors.backgroundDark,
                                child: const Icon(Icons.image, size: 48),
                              );
                            },
                          ),
                  ),
                ),
              );
            },
          ),
        ),
        if (widget.images.length > 1) ...[
          AppUtils().vSpace(size: DesignTokens.space16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.images.length,
              (index) => Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentPage == index
                      ? AppColors.primary
                      : AppColors.textSecondary.withOpacity(0.3),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
