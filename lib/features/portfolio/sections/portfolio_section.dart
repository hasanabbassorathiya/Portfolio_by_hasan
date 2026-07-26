import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/database/portfolio_repository.dart';
import '../../../shared/widgets/scroll_reveal.dart';
import '../../../shared/widgets/store_buttons.dart';
import '../../../shared/layouts/section_wrapper.dart';

class PortfolioSection extends StatefulWidget {
  const PortfolioSection({super.key});

  @override
  State<PortfolioSection> createState() => _PortfolioSectionState();
}

class _PortfolioSectionState extends State<PortfolioSection> {
  String _selectedFilter = 'All';
  late final List<Map<String, dynamic>> _projects;

  static const _filters = ['All', 'Mobile', 'FinTech'];

  @override
  void initState() {
    super.initState();
    _projects = PortfolioRepository().projects;
  }

  List<Map<String, dynamic>> get _filteredProjects {
    if (_selectedFilter == 'All') return _projects;
    return _projects.where((p) => p['category'] == _selectedFilter).toList();
  }

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
                  Text('WORK', style: AppTypography.label()),
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
                  'Selected projects.',
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
                'A showcase of impactful applications delivered for enterprise clients.',
                style: AppTypography.body(),
              ),
            ),
            const SizedBox(height: 48),
            ScrollReveal(
              direction: RevealDirection.up,
              delay: const Duration(milliseconds: 400),
              child: _buildFilters(),
            ),
            const SizedBox(height: 48),
            _buildBentoGrid(isMobile, isTablet),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Wrap(
      spacing: 8,
      children: _filters.map((f) {
        final isSelected = f == _selectedFilter;
        return GestureDetector(
          onTap: () => setState(() => _selectedFilter = f),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.accent : Colors.transparent,
              border: Border.all(
                color: isSelected ? AppColors.accent : AppColors.border,
                width: 2,
              ),
              boxShadow: [
                if (isSelected)
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.2),
                    offset: const Offset(2, 2),
                  ),
              ],
            ),
            child: Text(
              f.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isSelected ? AppColors.deep : AppColors.textSecondary,
                letterSpacing: 1,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBentoGrid(bool isMobile, bool isTablet) {
    final projects = _filteredProjects;

    if (isMobile) {
      return Column(
        children: List.generate(projects.length, (i) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ScrollReveal(
              direction: RevealDirection.up,
              delay: Duration(milliseconds: 100 * i),
              child: _ProjectCard(
                project: projects[i],
                onTap: () => context.push('/project/${projects[i]['id']}'),
              ),
            ),
          );
        }),
      );
    }

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: projects.isNotEmpty
                  ? ScrollReveal(
                      direction: RevealDirection.left,
                      delay: const Duration(milliseconds: 100),
                      child: _ProjectCard(
                        project: projects[0],
                        onTap: () => context.push('/project/${projects[0]['id']}'),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                children: [
                  if (projects.length > 1)
                    ScrollReveal(
                      direction: RevealDirection.right,
                      delay: const Duration(milliseconds: 200),
                      child: _ProjectCard(
                        project: projects[1],
                        onTap: () => context.push('/project/${projects[1]['id']}'),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (projects.length > 2)
              Expanded(
                child: ScrollReveal(
                  direction: RevealDirection.left,
                  delay: const Duration(milliseconds: 300),
                  child: _ProjectCard(
                    project: projects[2],
                    onTap: () => context.push('/project/${projects[2]['id']}'),
                  ),
                ),
              ),
            const SizedBox(width: 16),
            if (projects.length > 3)
              Expanded(
                child: ScrollReveal(
                  direction: RevealDirection.up,
                  delay: const Duration(milliseconds: 400),
                  child: _ProjectCard(
                    project: projects[3],
                    onTap: () => context.push('/project/${projects[3]['id']}'),
                  ),
                ),
              ),
            const SizedBox(width: 16),
            if (projects.length > 4)
              Expanded(
                child: ScrollReveal(
                  direction: RevealDirection.right,
                  delay: const Duration(milliseconds: 500),
                  child: _ProjectCard(
                    project: projects[4],
                    onTap: () => context.push('/project/${projects[4]['id']}'),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _ProjectCard extends StatefulWidget {
  final Map<String, dynamic> project;
  final VoidCallback onTap;

  const _ProjectCard({required this.project, required this.onTap});

  @override
  State<_ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<_ProjectCard> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final technologies = widget.project['technologies'];
    final techList = technologies is List ? technologies : <dynamic>[];

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
          transformAlignment: Alignment.center,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: _hovered ? AppColors.deep : AppColors.accent,
                    ),
                    child: Text(
                      (widget.project['category'] ?? '') as String,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _hovered ? AppColors.accent : AppColors.deep,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  Text(
                    (widget.project['year'] ?? '') as String,
                    style: TextStyle(
                      fontSize: 12,
                      color: _hovered ? AppColors.deep.withValues(alpha: 0.7) : AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                (widget.project['title'] ?? '') as String,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: _hovered ? AppColors.deep : AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                (widget.project['client'] ?? '') as String,
                style: TextStyle(
                  fontSize: 13,
                  color: _hovered ? AppColors.deep.withValues(alpha: 0.7) : AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Text(
                  (widget.project['description'] ?? '') as String,
                  style: TextStyle(
                    fontSize: 14,
                    color: _hovered ? AppColors.deep.withValues(alpha: 0.8) : AppColors.textSecondary,
                    height: 1.6,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: techList.take(4).map((t) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _hovered ? AppColors.deep : AppColors.surface,
                      border: Border.all(color: _hovered ? AppColors.deep : AppColors.border, width: 1),
                    ),
                    child: Text(
                      t.toString(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _hovered ? AppColors.accent : AppColors.textMuted,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              StoreButtons(
                iosUrl: widget.project['ios_url'] as String?,
                androidUrl: widget.project['android_url'] as String?,
                compact: true,
              ),
              const SizedBox(height: 16),
              Text(
                'VIEW PROJECT →',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _hovered ? AppColors.deep : AppColors.accent,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
