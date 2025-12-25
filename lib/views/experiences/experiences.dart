import 'package:flutter/material.dart';
import 'package:portfolio/core/repositories/experience_repository.dart';
import 'package:portfolio/shared/constants/colors.dart';
import 'package:portfolio/shared/constants/textstyles.dart';
import 'package:portfolio/shared/constants/utils.dart';
import 'package:portfolio/shared/widgets/gradient_text.dart';
import 'package:portfolio/shared/widgets/empty_state.dart';
import 'package:portfolio/core/services/analytics_service.dart';
import 'package:intl/intl.dart';

class Experiences extends StatefulWidget {
  final bool isActive;

  const Experiences({super.key, this.isActive = false});

  @override
  State<Experiences> createState() => _ExperiencesState();
}

class _ExperiencesState extends State<Experiences>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  final ExperienceRepository _experienceRepository = ExperienceRepository();
  List<ExperienceModel> _experiences = [];
  bool _isLoading = true;

  int? _expandedIndex;
  int? _hoveredIndex;

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
    _loadExperiences();
  }

  void _trackPageView() {
    AnalyticsService.trackPageView(
      pagePath: '/experiences',
      pageTitle: 'Experiences',
    );
  }

  Future<void> _loadExperiences() async {
    try {
      setState(() => _isLoading = true);
      final experiences = await _experienceRepository.getAllExperiences();
      setState(() {
        _experiences = experiences;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _activatePage() {
    _animationController.forward(from: 0.0);
  }

  @override
  void didUpdateWidget(covariant Experiences oldWidget) {
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

  void _toggleExpanded(int index) {
    setState(() {
      if (_expandedIndex == index) {
        _expandedIndex = null;
      } else {
        _expandedIndex = index;
      }
    });
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('MMM yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isSmall = screenWidth < 700;
    final bool isMedium = screenWidth < 1200 && !isSmall;
    final EdgeInsets pagePadding = EdgeInsets.symmetric(
      horizontal: isSmall ? 20 : isMedium ? 60 : 100,
      vertical: isSmall ? 20 : 60,
    );
    return Padding(
      padding: pagePadding,
      child: FadeTransition(
        opacity: _fadeInAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('EXPERIENCE', style: AppStyles.subheading(fontSize: 18)),
            AppUtils().vSpace(size: 12),
            Text(
              'MY WORK EXPERIENCE'.toUpperCase(),
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
            else if (_experiences.isEmpty)
              EmptyState(
                title: 'No Experience Yet',
                message: 'Work experience will appear here once added from the admin panel.',
                icon: Icons.work_outline,
              )
            else
              ..._buildExperiencesList(context, isSmall, isMedium),
            AppUtils().vSpace(size: 48),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildExperiencesList(
    BuildContext context,
    bool isSmall,
    bool isMedium,
  ) {
    final List<Widget> widgets = [];
    for (int i = 0; i < _experiences.length; i++) {
      final experience = _experiences[i];
      
      widgets.add(
        _buildExperienceItem(
          context,
          isSmall,
          isMedium,
          experience,
          i,
          _expandedIndex,
          _toggleExpanded,
        ),
      );
      
      if (i < _experiences.length - 1) {
        widgets.add(AppUtils().vSpace(size: 20));
        widgets.add(const Divider());
        widgets.add(AppUtils().vSpace(size: 20));
      }
    }
    return widgets;
  }

  Widget _buildExperienceItem(
    BuildContext context,
    bool isSmall,
    bool isMedium,
    ExperienceModel experience,
    int index,
    int? expandedIndex,
    Function(int) toggleExpanded,
  ) {
    final bool isExpanded = index == expandedIndex;
    final bool isHovered = index == _hoveredIndex;
    final String dateRange = experience.isCurrent
        ? '${_formatDate(experience.startDate)} - Present'
        : '${_formatDate(experience.startDate)} - ${_formatDate(experience.endDate)}';

    return InkWell(
      onTap: () => toggleExpanded(index),
      onHover: (hovering) {
        setState(() {
          _hoveredIndex = hovering ? index : null;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        decoration: BoxDecoration(
          color: isHovered
              ? AppColors.primaryColor.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '• ',
                            style: AppStyles.heading(
                              fontSize: isSmall ? 24 : 28,
                              fontWeight: FontWeight.bold,
                              color: isExpanded || isHovered
                                  ? AppColors.primaryColor
                                  : Colors.black,
                            ),
                          ),
                          Expanded(
                            child: isExpanded || isHovered
                                ? GradientText(
                                  experience.position.toUpperCase(),
                                  gradient: AppUtils().appGradient,
                                  style: AppStyles.heading(
                                    fontSize: isSmall ? 24 : 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                                : Text(
                                  experience.position.toUpperCase(),
                                  style: AppStyles.heading(
                                    fontSize: isSmall ? 24 : 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                          ),
                        ],
                      ),
                      if (experience.company.isNotEmpty) ...[
                        AppUtils().vSpace(size: 4),
                        Padding(
                          padding: const EdgeInsets.only(left: 24.0),
                          child: Text(
                            experience.company,
                            style: AppStyles.body(
                              fontSize: isSmall ? 14 : 16,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                      AppUtils().vSpace(size: 4),
                      Padding(
                        padding: const EdgeInsets.only(left: 24.0),
                        child: Text(
                          dateRange,
                          style: AppStyles.body(
                            fontSize: isSmall ? 12 : 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedRotation(
                  turns: isExpanded ? 0.25 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    isExpanded ? Icons.remove : Icons.add,
                    size: 24,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            if (isExpanded && experience.description != null && experience.description!.isNotEmpty) ...[
              AppUtils().vSpace(size: 12),
              Padding(
                padding: const EdgeInsets.only(left: 24.0),
                child: Text(
                  experience.description!,
                  style: AppStyles.body(fontSize: isSmall ? 14 : 16),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

