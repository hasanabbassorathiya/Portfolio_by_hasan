import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/layouts/section_wrapper.dart';
import '../../../shared/widgets/store_buttons.dart';
import '../../../data/projects_data.dart';

class ProjectDetailScreen extends StatelessWidget {
  final String projectId;

  const ProjectDetailScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    final project = AppProjectsData.featuredProjects.firstWhere(
      (p) => p['id'] == projectId,
      orElse: () => AppProjectsData.featuredProjects.first,
    );

    return Scaffold(
      backgroundColor: AppColors.deep,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, project),
            SectionWrapper(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoSection(project),
                  const SizedBox(height: 48),
                  _buildChallengeSolution(project),
                  const SizedBox(height: 48),
                  _buildTechStack(project),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Map<String, dynamic> project) {
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
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.accentSubtle,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              project['category'],
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.accent,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            project['title'],
            style: GoogleFonts.cormorant(
              fontSize: 48,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            project['client'] ?? '',
            style: GoogleFonts.montserrat(
              fontSize: 16,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 24),
          StoreButtons(
            iosUrl: project['ios_url'] as String?,
            androidUrl: project['android_url'] as String?,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(Map<String, dynamic> project) {
    return Row(
      children: [
        _buildInfoChip('Role', project['role'] ?? ''),
        const SizedBox(width: 16),
        _buildInfoChip('Year', project['year'] ?? ''),
        const SizedBox(width: 16),
        _buildInfoChip('Category', project['category']),
      ],
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.glassFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: GoogleFonts.montserrat(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeSolution(Map<String, dynamic> project) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'OVERVIEW',
          style: GoogleFonts.montserrat(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.accent,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          project['description'],
          style: GoogleFonts.montserrat(
            fontSize: 16,
            color: AppColors.textSecondary,
            height: 1.7,
          ),
        ),
        const SizedBox(height: 32),
        if (project['challenge'] != null) ...[
          Text(
            'CHALLENGE',
            style: GoogleFonts.montserrat(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.accent,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            project['challenge'],
            style: GoogleFonts.montserrat(
              fontSize: 15,
              color: AppColors.textSecondary,
              height: 1.7,
            ),
          ),
          const SizedBox(height: 32),
        ],
        if (project['solution'] != null) ...[
          Text(
            'SOLUTION',
            style: GoogleFonts.montserrat(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.accent,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            project['solution'],
            style: GoogleFonts.montserrat(
              fontSize: 15,
              color: AppColors.textSecondary,
              height: 1.7,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTechStack(Map<String, dynamic> project) {
    final techs = project['technologies'] as List;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TECHNOLOGIES',
          style: GoogleFonts.montserrat(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.accent,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: techs.map((t) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.accentSubtle,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
              ),
              child: Text(
                t,
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.accent,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
