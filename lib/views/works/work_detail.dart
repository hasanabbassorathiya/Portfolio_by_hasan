import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:portfolio/models/work/work_model.dart';
import 'package:portfolio/shared/constants/colors.dart';
import 'package:portfolio/shared/constants/design_tokens.dart';
import 'package:portfolio/shared/constants/textstyles.dart';
import 'package:portfolio/shared/constants/utils.dart';
import 'package:portfolio/shared/utils/responsive.dart';
import 'package:portfolio/shared/widgets/modern_button.dart';
import 'package:portfolio/shared/widgets/modern_card.dart';
import 'package:portfolio/shared/widgets/smooth_scroll_wrapper.dart';
import 'package:portfolio/core/services/analytics_service.dart';

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

  @override
  void initState() {
    super.initState();
    _work = WorkRepository.getWorkById(widget.workId);
    
    // Track work view
    if (_work != null) {
      AnalyticsService.trackWorkView(_work!.id);
      AnalyticsService.trackPageView(
        pagePath: '/works/${_work!.id}',
        pageTitle: _work!.title,
      );
    }

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

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            Image.asset(
              _work!.imageAsset,
              fit: BoxFit.cover,
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
        if (_work!.images != null && _work!.images!.isNotEmpty) ...[
          AppUtils().vSpace(size: DesignTokens.space32),
          _buildGallery(context),
        ],
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
          if (_work!.images != null && _work!.images!.isNotEmpty) ...[
            AppUtils().vSpace(size: DesignTokens.space40),
            _buildGallery(context),
          ],
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
            if (_work!.images != null && _work!.images!.isNotEmpty) ...[
              AppUtils().vSpace(size: DesignTokens.space48),
              _buildGallery(context),
            ],
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
                    _work!.images!.map((imagePath) {
                      return SizedBox(
                        width: itemWidth,
                        child: ModernCard(
                          padding: EdgeInsets.zero,
                          showGradientBorder: true,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                              DesignTokens.borderRadius12,
                            ),
                            child: Image.asset(
                              imagePath,
                              fit: BoxFit.cover,
                              height: 300,
                              width: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 300,
                                  color: AppColors.backgroundDark,
                                  child: const Icon(Icons.image, size: 48),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedWorks(BuildContext context) {
    final relatedWorks =
        WorkRepository.getAllWorks()
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
