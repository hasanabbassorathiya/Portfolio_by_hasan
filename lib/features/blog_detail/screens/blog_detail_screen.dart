import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/database/portfolio_repository.dart';
import '../../../shared/layouts/section_wrapper.dart';

class BlogDetailScreen extends StatelessWidget {
  final String slug;

  const BlogDetailScreen({super.key, required this.slug});

  @override
  Widget build(BuildContext context) {
    final posts = PortfolioRepository().posts;
    final post = posts.firstWhere(
      (p) => p['slug'] == slug,
      orElse: () => posts.first,
    );

    return Scaffold(
      backgroundColor: AppColors.deep,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, post),
            SectionWrapper(
              narrow: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post['title'],
                    style: GoogleFonts.cormorant(
                      fontSize: 40,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.accentSubtle,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          post['category'],
                          style: GoogleFonts.montserrat(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        post['read_time'] ?? '',
                        style: GoogleFonts.montserrat(
                          fontSize: 13,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        post['published_at'] ?? '',
                        style: GoogleFonts.montserrat(
                          fontSize: 13,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),
                  Text(
                    post['excerpt'] ?? '',
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      color: AppColors.textSecondary,
                      height: 1.7,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 48),
                  Text(
                    'This is a placeholder for the full blog post content. In a production setup, this would be fetched from the CMS or Turso database and rendered as rich text or markdown.',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                      height: 1.8,
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

  Widget _buildHeader(BuildContext context, Map<String, dynamic> post) {
    return Container(
      padding: const EdgeInsets.all(48),
      decoration: const BoxDecoration(
        color: AppColors.base,
        border: Border(bottom: BorderSide(color: AppColors.glassBorder)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_back, color: AppColors.textMuted, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Back',
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
