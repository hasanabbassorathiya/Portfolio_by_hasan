import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:portfolio/core/repositories/blog_repository.dart';
import 'package:portfolio/models/blog/blog_model.dart' hide BlogRepository;
import 'package:portfolio/shared/constants/colors.dart';
import 'package:portfolio/shared/constants/design_tokens.dart';
import 'package:portfolio/shared/constants/textstyles.dart';
import 'package:portfolio/shared/utils/responsive.dart';
import 'package:portfolio/shared/widgets/modern_button.dart';
import 'package:portfolio/shared/widgets/modern_card.dart';
import 'package:portfolio/shared/widgets/smooth_scroll_wrapper.dart';
import 'package:portfolio/shared/constants/utils.dart';
import 'package:portfolio/core/services/analytics_service.dart';
import 'package:url_launcher/url_launcher.dart';

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
  final BlogRepository _blogRepository = BlogRepository();
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _loadBlog();
  }

  Future<void> _loadBlog() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      debugPrint('BlogDetail: Loading blog with ID: ${widget.blogId}');
      final blog = await _blogRepository.getBlogById(widget.blogId);
      
      if (blog != null) {
        debugPrint('BlogDetail: Blog loaded successfully: ${blog.title}');
        // Track blog view
        AnalyticsService.trackBlogView(blog.id);
        AnalyticsService.trackPageView(
          pagePath: '/blogs/${blog.id}',
          pageTitle: blog.title,
        );
      } else {
        debugPrint('BlogDetail: Blog not found for ID: ${widget.blogId}');
      }

      setState(() {
        _blog = blog;
        _isLoading = false;
        _hasError = blog == null;
      });

    _controller.forward();
    } catch (e, stackTrace) {
      debugPrint('BlogDetail: Error loading blog: $e');
      debugPrint('BlogDetail: Stack trace: $stackTrace');
      setState(() {
        _isLoading = false;
        _hasError = true;
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
        backgroundColor: AppColors.bgColor,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_hasError || _blog == null) {
      return Scaffold(
        backgroundColor: AppColors.bgColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.textSecondary,
              ),
              AppUtils().vSpace(size: DesignTokens.space16),
              Text(
                'Blog not found',
                style: AppStyles.heading(context: context),
              ),
              AppUtils().vSpace(size: DesignTokens.space8),
              Text(
                'The blog you are looking for does not exist or has been removed.',
                style: AppStyles.body(
                  color: AppColors.textSecondary,
                  context: context,
                ),
                textAlign: TextAlign.center,
              ),
              AppUtils().vSpace(size: DesignTokens.space24),
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
            // Try network image first, then asset, then fallback
            _blog!.imageAsset.startsWith('http')
                ? Image.network(
              _blog!.imageAsset,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                      return _buildFallbackImage();
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                return Container(
                  color: AppColors.backgroundDark,
                        child: const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                      );
                    },
                  )
                : Image.asset(
                    _blog!.imageAsset,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildFallbackImage();
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
            // More visible back button
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
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                    onTap: () => context.go('/blogs'),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.arrow_back,
                                color: AppColors.primaryColor,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Back to Blogs',
                                style: AppStyles.body(
                                  color: AppColors.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
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

  Widget _buildFallbackImage() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryColor.withOpacity(0.8),
            AppColors.primaryColor.withOpacity(0.4),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.image, size: 64, color: Colors.white70),
            const SizedBox(height: 8),
            Text(
              'Image not available',
              style: AppStyles.body(color: Colors.white70),
            ),
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
        child: _blog!.content.trim().startsWith('<') ||
                _blog!.content.contains('<html') ||
                _blog!.content.contains('<p>') ||
                _blog!.content.contains('<div>')
            ? Padding(
                padding: const EdgeInsets.all(16),
                child: Html(
                  data: _sanitizeHtmlContent(_blog!.content),
                  style: {
                    'body': Style(
                      margin: Margins.zero,
                      padding: HtmlPaddings.zero,
                      fontSize: FontSize(16),
                      lineHeight: LineHeight(1.6),
                    ),
                    'h1': Style(
                      fontSize: FontSize(32),
                      fontWeight: FontWeight.bold,
                      margin: Margins.only(bottom: 16),
                    ),
                    'h2': Style(
                      fontSize: FontSize(24),
                      fontWeight: FontWeight.bold,
                      margin: Margins.only(bottom: 12, top: 24),
                    ),
                    'h3': Style(
                      fontSize: FontSize(20),
                      fontWeight: FontWeight.bold,
                      margin: Margins.only(bottom: 8, top: 16),
                    ),
                    'p': Style(
                      margin: Margins.only(bottom: 16),
                    ),
                    'img': Style(
                      width: Width(MediaQuery.of(context).size.width - 100),
                    ),
                  },
                  extensions: [
                    ImageExtension(),
                  ],
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [..._parseContent(_blog!.content)],
                ),
        ),
      ),
    );
  }

  /// Sanitize HTML content to fix image URLs
  String _sanitizeHtmlContent(String content) {
    // Fix URLs that were incorrectly prefixed with "assets/"
    // Simple string replacement approach
    String sanitized = content;
    
    // Remove "assets/" prefix from http/https URLs
    sanitized = sanitized.replaceAll('src="assets/http', 'src="http');
    sanitized = sanitized.replaceAll("src='assets/http", "src='http");
    
    // Decode double-encoded URLs (https%253A%2F%2F -> https://)
    try {
      sanitized = Uri.decodeComponent(sanitized);
      // If still encoded, decode again
      if (sanitized.contains('%')) {
        sanitized = Uri.decodeComponent(sanitized);
      }
    } catch (e) {
      // If decoding fails, continue with original
    }
    
    return sanitized;
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
    final blogUrl = '${Uri.base.origin}/blogs/${_blog!.id}';
    final shareText = 'Check out this article: ${_blog!.title}';
    
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
                  'https://twitter.com/intent/tweet?text=${Uri.encodeComponent(shareText)}&url=${Uri.encodeComponent(blogUrl)}',
                ),
                _buildShareButton(
                  context,
                  'LinkedIn',
                  Icons.business,
                  AppColors.primary,
                  'https://www.linkedin.com/sharing/share-offsite/?url=${Uri.encodeComponent(blogUrl)}',
                ),
                _buildShareButton(
                  context,
                  'Facebook',
                  Icons.facebook,
                  AppColors.primary,
                  'https://www.facebook.com/sharer/sharer.php?u=${Uri.encodeComponent(blogUrl)}',
                ),
                _buildShareButton(
                  context,
                  'WhatsApp',
                  Icons.chat,
                  AppColors.primary,
                  'https://wa.me/?text=${Uri.encodeComponent('$shareText $blogUrl')}',
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
    String shareUrl,
  ) {
    return InkWell(
      onTap: () async {
        // Track social share click
        AnalyticsService.trackEvent(
          eventName: 'social_share_clicked',
          eventData: {
            'platform': label.toLowerCase(),
            'blog_id': _blog?.id,
            'blog_title': _blog?.title,
          },
        );

        final uri = Uri.parse(shareUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Could not launch $label')),
            );
          }
        }
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
    // For now, return empty since we need async loading
    // TODO: Implement related blogs loading with async repository
    return const SizedBox.shrink();
  }
}
