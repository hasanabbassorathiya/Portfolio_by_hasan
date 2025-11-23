import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:portfolio/models/blog/blog_model.dart';
import 'package:portfolio/shared/constants/colors.dart';
import 'package:portfolio/shared/constants/design_tokens.dart';
import 'package:portfolio/shared/constants/textstyles.dart';
import 'package:portfolio/shared/utils/responsive.dart';
import 'package:portfolio/shared/widgets/modern_button.dart';
import 'package:portfolio/shared/widgets/modern_card.dart';
import 'package:portfolio/shared/widgets/smooth_scroll_wrapper.dart';
import 'package:portfolio/shared/constants/utils.dart';
import 'package:portfolio/core/services/analytics_service.dart';

/// Blog detail page
/// Displays full blog post content with modern UI
/// Inspired by modern portfolio blog layouts
class BlogDetail extends StatefulWidget {
  final String blogId;

  const BlogDetail({super.key, required this.blogId});

  @override
  State<BlogDetail> createState() => _BlogDetailState();
}

class _BlogDetailState extends State<BlogDetail>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  BlogModel? _blog;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _blog = BlogRepository.getBlogById(widget.blogId);
    
    // Track blog view
    if (_blog != null) {
      AnalyticsService.trackBlogView(_blog!.id);
      AnalyticsService.trackPageView(
        pagePath: '/blogs/${_blog!.id}',
        pageTitle: _blog!.title,
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
    if (_blog == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Blog not found'),
              AppUtils().vSpace(size: DesignTokens.space16),
              ModernButton(
                title: 'Back to Blogs',
                onTap: () => context.go('/blogs'),
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

  /// Hero section with featured image
  Widget _buildHeroSection(BuildContext context) {
    return AnimatedSection(
      delay: Duration.zero,
      child: Container(
        width: double.infinity,
        height: Responsive.value<double>(
          context: context,
          mobile: 300,
          tablet: 400,
          desktop: 500,
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
              _blog!.imageAsset,
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
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.7),
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
                    onTap: () => context.go('/blogs'),
                    padding: const EdgeInsets.all(DesignTokens.space12),
                  ),
                  const Spacer(),
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
                  if (_blog!.category != null)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: DesignTokens.space12,
                        vertical: DesignTokens.space6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.gradientOrange.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(
                          DesignTokens.borderRadius4,
                        ),
                      ),
                      child: Text(
                        _blog!.category!.toUpperCase(),
                        style: AppStyles.body(
                          fontSize: DesignTokens.fontSize12,
                          color: Colors.white,
                          context: context,
                        ),
                      ),
                    ),
                  AppUtils().vSpace(size: DesignTokens.space16),
                  Text(
                    _blog!.title,
                    style: AppStyles.heading(
                      fontSize: Responsive.fontSize(
                        context,
                        DesignTokens.fontSize32,
                      ),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      context: context,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  AppUtils().vSpace(size: DesignTokens.space12),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: DesignTokens.iconSize16,
                        color: Colors.white70,
                      ),
                      AppUtils().hSpace(size: DesignTokens.space8),
                      Text(
                        _blog!.date,
                        style: AppStyles.body(
                          fontSize: DesignTokens.fontSize14,
                          color: Colors.white70,
                          context: context,
                        ),
                      ),
                      if (_blog!.readTime != null) ...[
                        AppUtils().hSpace(size: DesignTokens.space16),
                        Icon(
                          Icons.access_time,
                          size: DesignTokens.iconSize16,
                          color: Colors.white70,
                        ),
                        AppUtils().hSpace(size: DesignTokens.space8),
                        Text(
                          _blog!.readTime!,
                          style: AppStyles.body(
                            fontSize: DesignTokens.fontSize14,
                            color: Colors.white70,
                            context: context,
                          ),
                        ),
                      ],
                    ],
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
        _buildAuthorSection(context),
        AppUtils().vSpace(size: DesignTokens.space32),
        _buildContent(context),
        AppUtils().vSpace(size: DesignTokens.space32),
        _buildTags(context),
        AppUtils().vSpace(size: DesignTokens.space32),
        _buildShareSection(context),
        AppUtils().vSpace(size: DesignTokens.space48),
        _buildRelatedBlogs(context),
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
          _buildAuthorSection(context),
          AppUtils().vSpace(size: DesignTokens.space40),
          _buildContent(context),
          AppUtils().vSpace(size: DesignTokens.space40),
          _buildTags(context),
          AppUtils().vSpace(size: DesignTokens.space40),
          _buildShareSection(context),
          AppUtils().vSpace(size: DesignTokens.space56),
          _buildRelatedBlogs(context),
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main content
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppUtils().vSpace(size: DesignTokens.space48),
                  _buildAuthorSection(context),
                  AppUtils().vSpace(size: DesignTokens.space48),
                  _buildContent(context),
                  AppUtils().vSpace(size: DesignTokens.space48),
                  _buildTags(context),
                  AppUtils().vSpace(size: DesignTokens.space48),
                  _buildShareSection(context),
                  AppUtils().vSpace(size: DesignTokens.space64),
                  _buildRelatedBlogs(context),
                  AppUtils().vSpace(size: DesignTokens.space64),
                ],
              ),
            ),
            // Sidebar
            AppUtils().hSpace(size: DesignTokens.space48),
            SizedBox(
              width: 280,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppUtils().vSpace(size: DesignTokens.space48),
                  _buildTableOfContents(context),
                  AppUtils().vSpace(size: DesignTokens.space32),
                  _buildAuthorCard(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthorSection(BuildContext context) {
    return AnimatedSection(
      delay: const Duration(milliseconds: 100),
      child: ModernCard(
        child: Row(
          children: [
            CircleAvatar(
              radius: Responsive.value<double>(
                context: context,
                mobile: 30,
                tablet: 35,
                desktop: 40,
              ),
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Icon(
                Icons.person,
                size: Responsive.value<double>(
                  context: context,
                  mobile: 30,
                  tablet: 35,
                  desktop: 40,
                ),
                color: AppColors.primary,
              ),
            ),
            AppUtils().hSpace(size: DesignTokens.space16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _blog!.author,
                    style: AppStyles.titleMedium(context: context),
                  ),
                  AppUtils().vSpace(size: DesignTokens.space4),
                  Text(
                    'Published on ${_blog!.date}',
                    style: AppStyles.body(
                      fontSize: DesignTokens.fontSize14,
                      color: AppColors.textSecondary,
                      context: context,
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

  Widget _buildAuthorCard(BuildContext context) {
    return AnimatedSection(
      delay: const Duration(milliseconds: 200),
      child: ModernCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Icon(Icons.person, size: 30, color: AppColors.primary),
                ),
                AppUtils().hSpace(size: DesignTokens.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _blog!.author,
                        style: AppStyles.titleSmall(context: context),
                      ),
                      Text(
                        'Flutter Developer',
                        style: AppStyles.body(
                          fontSize: DesignTokens.fontSize12,
                          color: AppColors.textSecondary,
                          context: context,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            AppUtils().vSpace(size: DesignTokens.space16),
            Text(
              'Passionate about creating beautiful and functional mobile applications.',
              style: AppStyles.body(context: context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableOfContents(BuildContext context) {
    // Extract headings from content for TOC
    final headings = <String>[];
    final lines = _blog!.content.split('\n');
    for (final line in lines) {
      if (line.startsWith('## ')) {
        headings.add(line.substring(3).trim());
      }
    }

    if (headings.isEmpty) return const SizedBox.shrink();

    return AnimatedSection(
      delay: const Duration(milliseconds: 150),
      child: ModernCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Table of Contents',
              style: AppStyles.titleSmall(context: context),
            ),
            AppUtils().vSpace(size: DesignTokens.space16),
            ...headings.asMap().entries.map((entry) {
              return Padding(
                padding: EdgeInsets.only(bottom: DesignTokens.space8),
                child: InkWell(
                  onTap: () {
                    // Scroll to section
                  },
                  child: Text(
                    '${entry.key + 1}. ${entry.value}',
                    style: AppStyles.body(
                      fontSize: DesignTokens.fontSize14,
                      color: AppColors.primary,
                      context: context,
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return AnimatedSection(
      delay: const Duration(milliseconds: 200),
      child: ModernCard(
        backgroundColor: AppColors.bgColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [..._parseContent(_blog!.content)],
        ),
      ),
    );
  }

  List<Widget> _parseContent(String content) {
    final lines = content.split('\n');
    final widgets = <Widget>[];

    for (final line in lines) {
      if (line.trim().isEmpty) {
        widgets.add(AppUtils().vSpace(size: DesignTokens.space16));
        continue;
      }

      if (line.startsWith('# ')) {
        widgets.add(
          Text(
            line.substring(2),
            style: AppStyles.heading(
              fontSize: DesignTokens.fontSize32,
              fontWeight: FontWeight.bold,
              context: null,
            ),
          ),
        );
        widgets.add(AppUtils().vSpace(size: DesignTokens.space16));
      } else if (line.startsWith('## ')) {
        widgets.add(
          Text(line.substring(3), style: AppStyles.titleLarge(context: null)),
        );
        widgets.add(AppUtils().vSpace(size: DesignTokens.space12));
      } else if (line.startsWith('**') && line.endsWith('**')) {
        widgets.add(
          Text(
            line.substring(2, line.length - 2),
            style: AppStyles.body(fontWeight: FontWeight.bold, context: null),
          ),
        );
      } else if (line.startsWith('1. ') || line.startsWith('- ')) {
        widgets.add(
          Padding(
            padding: EdgeInsets.only(left: DesignTokens.space16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• ', style: AppStyles.body(context: null)),
                Expanded(
                  child: Text(
                    line.substring(2),
                    style: AppStyles.body(context: null),
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        widgets.add(Text(line, style: AppStyles.bodyLarge(context: null)));
      }
    }

    return widgets;
  }

  Widget _buildTags(BuildContext context) {
    if (_blog!.tags.isEmpty) return const SizedBox.shrink();

    return AnimatedSection(
      delay: const Duration(milliseconds: 300),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tags', style: AppStyles.subheading(context: context)),
          AppUtils().vSpace(size: DesignTokens.space16),
          Wrap(
            spacing: DesignTokens.space12,
            runSpacing: DesignTokens.space12,
            children:
                _blog!.tags.map((tag) {
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

  Widget _buildShareSection(BuildContext context) {
    return AnimatedSection(
      delay: const Duration(milliseconds: 400),
      child: ModernCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Share this article',
              style: AppStyles.titleSmall(context: context),
            ),
            AppUtils().vSpace(size: DesignTokens.space16),
            Wrap(
              spacing: DesignTokens.space12,
              runSpacing: DesignTokens.space12,
              children: [
                _buildShareButton(
                  context,
                  'Twitter',
                  Icons.share,
                  AppColors.primary,
                ),
                _buildShareButton(
                  context,
                  'LinkedIn',
                  Icons.business,
                  AppColors.primary,
                ),
                _buildShareButton(
                  context,
                  'Facebook',
                  Icons.facebook,
                  AppColors.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
  ) {
    return InkWell(
      onTap: () {
        // Handle share
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: DesignTokens.space16,
          vertical: DesignTokens.space12,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(DesignTokens.borderRadius8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: DesignTokens.iconSize20, color: color),
            AppUtils().hSpace(size: DesignTokens.space8),
            Text(label, style: AppStyles.body(color: color, context: context)),
          ],
        ),
      ),
    );
  }

  Widget _buildRelatedBlogs(BuildContext context) {
    final relatedBlogs =
        BlogRepository.getAllBlogs()
            .where((blog) => blog.id != _blog!.id)
            .take(3)
            .toList();

    if (relatedBlogs.isEmpty) return const SizedBox.shrink();

    return AnimatedSection(
      delay: const Duration(milliseconds: 500),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Related Articles',
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
                    relatedBlogs.map((blog) {
                      return SizedBox(
                        width: itemWidth,
                        child: _buildBlogCard(blog),
                      );
                    }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBlogCard(BlogModel blog) {
    return ModernCard(
      onTap: () => context.go('/blogs/${blog.id}'),
      showGradientBorder: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(DesignTokens.borderRadius8),
            child: Image.asset(
              blog.imageAsset,
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
            blog.date,
            style: AppStyles.body(
              fontSize: DesignTokens.fontSize12,
              color: AppColors.textSecondary,
              context: null,
            ),
          ),
          AppUtils().vSpace(size: DesignTokens.space8),
          Text(
            blog.title,
            style: AppStyles.titleMedium(context: null),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
