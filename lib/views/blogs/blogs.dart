import 'package:flutter/material.dart';
import 'package:portfolio/core/repositories/blog_repository.dart';
import 'package:portfolio/models/blog/blog_model.dart' hide BlogRepository;
import 'package:portfolio/shared/constants/textstyles.dart';
import 'package:portfolio/shared/constants/utils.dart';
import 'package:portfolio/shared/widgets/modern_button.dart';
import 'package:portfolio/shared/widgets/empty_state.dart';
import 'package:portfolio/core/services/analytics_service.dart';
import 'blog_card.dart';

class Blogs extends StatefulWidget {
  final bool isActive;

  const Blogs({super.key, this.isActive = false});

  @override
  State<Blogs> createState() => _BlogsState();
}

class _BlogsState extends State<Blogs> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  final BlogRepository _blogRepository = BlogRepository();

  List<BlogModel> _blogPosts = [];
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _trackPageView();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeInAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _loadBlogs();
  }

  void _trackPageView() {
    AnalyticsService.trackPageView(
      pagePath: '/blogs',
      pageTitle: 'Blogs',
    );
  }

  Future<void> _loadBlogs() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });
      final blogs = await _blogRepository.getAllBlogs();
      setState(() {
        _blogPosts = blogs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _activatePage() {
    _animationController.forward(from: 0.0);
  }

  @override
  void didUpdateWidget(covariant Blogs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _activatePage();
    } else if (!widget.isActive && oldWidget.isActive) {
      _animationController.reset();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isSmall = screenWidth < 700;
    final bool isMedium = screenWidth < 1200 && !isSmall;
    final EdgeInsets pagePadding = EdgeInsets.symmetric(
      horizontal:
          isSmall
              ? 24
              : isMedium
              ? 72
              : 120,
      vertical: isSmall ? 32 : 80,
    );
    return Padding(
      padding: pagePadding,
      child: FadeTransition(
        opacity: _fadeInAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Blog', style: AppStyles.subheading(fontSize: 18)),
            AppUtils().vSpace(size: 12),
            Text(
              'READ MY BLOG'.toUpperCase(),
              style: AppStyles.heading(
                fontSize: isSmall ? 32 : 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            AppUtils().vSpace(size: 48),
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(48.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_hasError)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(48.0),
                  child: Column(
                    children: [
                      Text(
                        'Error loading blogs',
                        style: AppStyles.heading(fontSize: 24),
                      ),
                      AppUtils().vSpace(size: 16),
                      Text(
                        _errorMessage ?? 'Unknown error',
                        style: AppStyles.body(),
                        textAlign: TextAlign.center,
                      ),
                      AppUtils().vSpace(size: 24),
                      ElevatedButton(
                        onPressed: _loadBlogs,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            else if (_blogPosts.isEmpty)
              EmptyState(
                title: 'No Blog Posts Yet',
                message: 'Check back soon for new articles and insights!',
                icon: Icons.article_outlined,
              )
            else ...[
              LayoutBuilder(
                builder: (context, constraints) {
                  int columns =
                      isSmall
                          ? 1
                          : isMedium
                          ? 2
                          : 3;
                  double spacing = isSmall ? 16.0 : 32.0;
                  double itemWidth =
                      (constraints.maxWidth - (columns - 1) * spacing) /
                      columns;
                  if (itemWidth < 200) {
                    itemWidth = constraints.maxWidth;
                    columns = 1;
                  }
                  List<Widget> blogItems =
                      _blogPosts.map((blog) {
                        return SizedBox(
                          width: itemWidth,
                          child: BlogCard(
                            imageAsset: blog.imageAsset,
                            date: blog.date,
                            title: blog.title,
                            blogId: blog.id,
                          ),
                        );
                      }).toList();
                  return Wrap(
                    spacing: spacing,
                    runSpacing: spacing,
                    alignment: WrapAlignment.start,
                    children: blogItems,
                  );
                },
              ),
              AppUtils().vSpace(size: 64),
              // Load More Button (only show if there might be more)
              if (_blogPosts.length >= 6)
                Align(
                  alignment: Alignment.center,
                  child: ModernButton(
                    title: 'Load more',
                    icon: Icons.arrow_forward,
                    onTap: () {
                      // TODO: Implement pagination
                    },
                  ),
                ),
            ],
            AppUtils().vSpace(size: 80), // Increased space after the button
          ],
        ),
      ),
    );
  }
}
