import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/blog_data.dart';
import '../../../shared/widgets/scroll_reveal.dart';
import '../../../shared/layouts/section_wrapper.dart';

class BlogSection extends StatelessWidget {
  const BlogSection({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final isMobile = w < 600;
    final isTablet = w < 1200;

    return Container(
      color: AppColors.deep,
      child: SectionWrapper(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ScrollReveal(
              direction: RevealDirection.up,
              child: Row(
                children: [
                  Container(width: 32, height: 2, color: AppColors.accent),
                  const SizedBox(width: 16),
                  Text('BLOG', style: AppTypography.label()),
                ],
              ),
            ),
            const SizedBox(height: 40),
            ScrollReveal(
              direction: RevealDirection.up,
              delay: const Duration(milliseconds: 200),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: Text(
                  'Thoughts & insights.',
                  style: TextStyle(
                    fontSize: isMobile ? 36 : 52,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                    height: 1.1,
                    letterSpacing: -1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ScrollReveal(
              direction: RevealDirection.up,
              delay: const Duration(milliseconds: 300),
              child: Text(
                'Articles on Flutter architecture, AI integration, and engineering leadership.',
                style: AppTypography.body(),
              ),
            ),
            const SizedBox(height: 64),
            if (isMobile)
              Column(
                children: List.generate(AppBlogData.posts.length, (i) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: ScrollReveal(
                      direction: RevealDirection.up,
                      delay: Duration(milliseconds: 150 * i),
                      child: _BlogCard(
                        post: AppBlogData.posts[i],
                        onTap: () => context.push('/blog/${AppBlogData.posts[i]['slug']}'),
                      ),
                    ),
                  );
                }),
              )
            else
              _buildGrid(context, isTablet),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(BuildContext context, bool isTablet) {
    final posts = AppBlogData.posts;

    if (isTablet) {
      return Column(
        children: List.generate(
          (posts.length / 2).ceil(),
          (rowIndex) {
            final startIdx = rowIndex * 2;
            final remaining = (posts.length - startIdx).clamp(0, 2);

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(remaining, (colIdx) {
                  final idx = startIdx + colIdx;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: colIdx < remaining - 1 ? 16 : 0),
                      child: ScrollReveal(
                        direction: colIdx.isEven ? RevealDirection.left : RevealDirection.right,
                        delay: Duration(milliseconds: 200 * idx),
                        child: _BlogCard(
                          post: posts[idx],
                          onTap: () => context.push('/blog/${posts[idx]['slug']}'),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            );
          },
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(posts.length, (i) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < posts.length - 1 ? 16 : 0),
            child: ScrollReveal(
              direction: RevealDirection.up,
              delay: Duration(milliseconds: 200 * i),
              child: _BlogCard(
                post: posts[i],
                onTap: () => context.push('/blog/${posts[i]['slug']}'),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _BlogCard extends StatefulWidget {
  final Map<String, dynamic> post;
  final VoidCallback onTap;

  const _BlogCard({required this.post, required this.onTap});

  @override
  State<_BlogCard> createState() => _BlogCardState();
}

class _BlogCardState extends State<_BlogCard> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
          transform: _pressed
              ? (Matrix4.identity()..translate(2.0, 2.0))
              : Matrix4.identity(),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: _hovered ? AppColors.accent : AppColors.base,
            border: Border.all(
              color: _hovered ? AppColors.accent : AppColors.border,
              width: 2,
            ),
            boxShadow: [
              if (!_pressed && _hovered)
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.3),
                  offset: const Offset(4, 4),
                ),
              if (!_pressed && !_hovered)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  offset: const Offset(4, 4),
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: _hovered ? AppColors.deep : AppColors.accent,
                ),
                child: Text(
                  widget.post['category'].toString().toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _hovered ? AppColors.accent : AppColors.deep,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Text(
                  widget.post['title'],
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: _hovered ? AppColors.deep : AppColors.textPrimary,
                    height: 1.2,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.post['excerpt'],
                style: TextStyle(
                  fontSize: 13,
                  color: _hovered ? AppColors.deep.withValues(alpha: 0.8) : AppColors.textSecondary,
                  height: 1.6,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.post['readTime'] ?? '',
                    style: TextStyle(
                      fontSize: 12,
                      color: _hovered ? AppColors.deep.withValues(alpha: 0.6) : AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'READ →',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _hovered ? AppColors.deep : AppColors.accent,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
