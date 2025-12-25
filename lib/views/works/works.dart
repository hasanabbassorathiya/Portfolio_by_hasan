import 'package:flutter/material.dart';
import 'dart:async';
import 'package:portfolio/core/repositories/work_repository.dart';
import 'package:portfolio/core/repositories/testimonial_repository.dart' show TestimonialRepository, TestimonialModel;
import 'package:portfolio/models/work/work_model.dart' hide WorkRepository;
import 'package:portfolio/core/services/analytics_service.dart';
import 'work_card.dart';
import 'package:portfolio/shared/constants/textstyles.dart';
import 'package:portfolio/shared/constants/utils.dart';
import 'package:portfolio/shared/widgets/modern_button.dart';
import 'package:portfolio/shared/widgets/empty_state.dart';
import 'package:portfolio/shared/constants/colors.dart';

class Works extends StatefulWidget {
  final bool isActive;

  const Works({super.key, this.isActive = false});

  @override
  State<Works> createState() => _WorksState();
}

class _WorksState extends State<Works> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  final WorkRepository _workRepository = WorkRepository();
  final TestimonialRepository _testimonialRepository = TestimonialRepository();

  List<WorkModel> _projects = [];
  List<TestimonialModel> _testimonials = [];
  int _currentTestimonialIndex = 0;
  bool _isLoading = true;
  bool _hasError = false;
  Timer? _testimonialTimer;

  // Add hover state for testimonial navigation buttons
  bool _isHoveringPrev = false;
  bool _isHoveringNext = false;

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
    _loadData();
    _startTestimonialAutoScroll();
  }

  void _startTestimonialAutoScroll() {
    _testimonialTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_testimonials.isNotEmpty && mounted) {
        setState(() {
          _currentTestimonialIndex = (_currentTestimonialIndex + 1) % _testimonials.length;
        });
      }
    });
  }

  void _trackPageView() {
    AnalyticsService.trackPageView(
      pagePath: '/works',
      pageTitle: 'Works',
    );
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });
      final works = await _workRepository.getAllWorks();
      final testimonials = await _testimonialRepository.getActiveTestimonials();
      setState(() {
        _projects = works;
        _testimonials = testimonials;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  void _activatePage() {
    _animationController.forward(from: 0.0);
  }

  @override
  void didUpdateWidget(covariant Works oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _activatePage();
    } else if (!widget.isActive && oldWidget.isActive) {
      _animationController.reset();
    }
  }

  @override
  void dispose() {
    _testimonialTimer?.cancel();
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
              ? 20
              : isMedium
              ? 60
              : 100,
      vertical: isSmall ? 20 : 60,
    );
    return Padding(
      padding: pagePadding,
      child: FadeTransition(
        opacity: _fadeInAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Work', style: AppStyles.subheading(fontSize: 18)),
            AppUtils().vSpace(size: 12),
            Text(
              'RECENT PROJECT'.toUpperCase(),
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
                        'Error loading works',
                        style: AppStyles.heading(fontSize: 24),
                      ),
                      AppUtils().vSpace(size: 24),
                      ElevatedButton(
                        onPressed: _loadData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            else if (_projects.isEmpty)
              EmptyState(
                title: 'No Projects Yet',
                message: 'Portfolio projects will appear here soon!',
                icon: Icons.work_outline,
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
                  double availableWidth = constraints.maxWidth;
                  double itemWidth =
                      (availableWidth - (columns - 1) * spacing) / columns;
                  if (itemWidth < 200) {
                    itemWidth = availableWidth;
                    columns = 1;
                  }
                  List<Widget> projectItems =
                      _projects.map((project) {
                        return SizedBox(
                          width: itemWidth,
                          child: WorkCard(
                            imageAsset: project.imageAsset,
                            category: project.category,
                            title: project.title,
                            tags: project.tags,
                            description: project.description,
                            projectUrl: project.projectUrl,
                            workId: project.id,
                            appIconUrl: project.appIconUrl,
                          ),
                        );
                      }).toList();
                  return Wrap(
                    spacing: spacing,
                    runSpacing: spacing,
                    alignment: WrapAlignment.start,
                    children: projectItems,
                  );
                },
              ),
              AppUtils().vSpace(size: 48),
              if (_projects.length >= 6)
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

            AppUtils().vSpace(size: 80), // Space before testimonial section
            // Testimonial Section
            Container(
              padding: EdgeInsets.symmetric(
                horizontal:
                    isSmall
                        ? 20
                        : isMedium
                        ? 60
                        : 100,
                vertical: isSmall ? 40 : 80,
              ),
              decoration: BoxDecoration(
                gradient: AppUtils().appGradient,
              ), // Apply gradient background
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.center, // Center content horizontally
                children: [
                  Text(
                    'Testimonial', // Subheading
                    style: AppStyles.subheading(
                      color: AppColors.bgColor, // White text for subheading
                      fontSize: isSmall ? 16 : 18,
                    ),
                  ),
                  AppUtils().vSpace(size: 12),
                  Text(
                    'WHAT THEY SAYS'.toUpperCase(), // Heading
                    style: AppStyles.heading(
                      color: AppColors.bgColor, // White text for heading
                      fontSize: isSmall ? 32 : 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  AppUtils().vSpace(size: 40),

                  // Testimonial Layout matching Figma design
                  if (_testimonials.isEmpty)
                    Text(
                      'No testimonials yet',
                      textAlign: TextAlign.center,
                      style: AppStyles.heading(
                        fontSize: isSmall ? 18 : 24,
                      ).copyWith(color: AppColors.bgColor),
                    )
                  else
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final testimonial = _testimonials[_currentTestimonialIndex];
                        final bool isVerticalLayout = isSmall || constraints.maxWidth < 900;
                        
                        if (isVerticalLayout) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Client Image
                              if (testimonial.clientImageUrl != null && testimonial.clientImageUrl!.isNotEmpty)
                                Container(
                                  width: 200,
                                  height: 200,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.bgColor.withOpacity(0.3),
                                      width: 2,
                                    ),
                                  ),
                                  child: ClipOval(
                                    child: Image.network(
                                      testimonial.clientImageUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          color: AppColors.bgColor.withOpacity(0.2),
                                          child: Icon(
                                            Icons.person,
                                            size: 80,
                                            color: AppColors.bgColor,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              AppUtils().vSpace(size: 24),
                              // Quote
                              SizedBox(
                                width: double.infinity,
                                child: Text(
                                  '"${testimonial.quote}"',
                                  textAlign: TextAlign.center,
                                  style: AppStyles.heading(
                                    fontSize: isSmall ? 24 : 32,
                                    fontWeight: FontWeight.w600,
                                  ).copyWith(
                                    color: AppColors.bgColor,
                                  ),
                                ),
                              ),
                              AppUtils().vSpace(size: 40),
                              // Author Info
                              Column(
                                children: [
                                  Text(
                                    '-${testimonial.clientName}',
                                    style: AppStyles.subheading(
                                      color: AppColors.bgColor,
                                      fontSize: isSmall ? 20 : 24,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (testimonial.clientRole != null || testimonial.clientCompany != null) ...[
                                    AppUtils().vSpace(size: 6),
                                    Text(
                                      testimonial.clientRole != null && testimonial.clientCompany != null
                                          ? '${testimonial.clientRole}, ${testimonial.clientCompany}'
                                          : testimonial.clientRole ?? testimonial.clientCompany ?? '',
                                      style: AppStyles.body(
                                        fontSize: isSmall ? 14 : 16,
                                      ).copyWith(
                                        color: AppColors.bgColor.withOpacity(0.8),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          );
                        } else {
                          // Horizontal layout matching Figma
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Client Image on left
                              if (testimonial.clientImageUrl != null && testimonial.clientImageUrl!.isNotEmpty)
                                Container(
                                  width: 345,
                                  height: 477,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      testimonial.clientImageUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          color: AppColors.bgColor.withOpacity(0.2),
                                          child: Icon(
                                            Icons.person,
                                            size: 100,
                                            color: AppColors.bgColor,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              AppUtils().hSpace(size: 56),
                              // Quote and Author in center
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Quote
                                    Text(
                                      '"${testimonial.quote}"',
                                      style: AppStyles.heading(
                                        fontSize: 32,
                                        fontWeight: FontWeight.w600,
                                      ).copyWith(
                                        color: AppColors.bgColor,
                                      ),
                                    ),
                                    AppUtils().vSpace(size: 56),
                                    // Author Info
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '-${testimonial.clientName}',
                                          style: AppStyles.subheading(
                                            color: AppColors.bgColor,
                                            fontSize: 24,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        if (testimonial.clientRole != null || testimonial.clientCompany != null) ...[
                                          AppUtils().vSpace(size: 6),
                                          Text(
                                            testimonial.clientRole != null && testimonial.clientCompany != null
                                                ? '${testimonial.clientRole}, ${testimonial.clientCompany}'
                                                : testimonial.clientRole ?? testimonial.clientCompany ?? '',
                                            style: AppStyles.body(
                                              fontSize: 16,
                                            ).copyWith(
                                              color: AppColors.bgColor.withOpacity(0.8),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // Navigation Arrows on right
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  MouseRegion(
                                    onEnter: (_) => setState(() => _isHoveringPrev = true),
                                    onExit: (_) => setState(() => _isHoveringPrev = false),
                                    child: InkWell(
                                      onTap: () {
                                        if (_testimonials.isNotEmpty) {
                                          setState(() {
                                            _currentTestimonialIndex = (_currentTestimonialIndex - 1) % _testimonials.length;
                                          });
                                          _testimonialTimer?.cancel();
                                          _startTestimonialAutoScroll();
                                        }
                                      },
                                      child: Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          color: _isHoveringPrev
                                              ? AppColors.bgColor.withOpacity(0.3)
                                              : AppColors.bgColor.withOpacity(0.2),
                                          shape: BoxShape.circle,
                                          boxShadow: _isHoveringPrev
                                              ? [
                                                  BoxShadow(
                                                    color: Colors.orange.withOpacity(0.5),
                                                    blurRadius: 25,
                                                    spreadRadius: 0,
                                                  ),
                                                ]
                                              : null,
                                        ),
                                        child: Icon(
                                          Icons.arrow_back,
                                          color: AppColors.bgColor,
                                          size: 24,
                                        ),
                                      ),
                                    ),
                                  ),
                                  AppUtils().vSpace(size: 14),
                                  MouseRegion(
                                    onEnter: (_) => setState(() => _isHoveringNext = true),
                                    onExit: (_) => setState(() => _isHoveringNext = false),
                                    child: InkWell(
                                      onTap: () {
                                        if (_testimonials.isNotEmpty) {
                                          setState(() {
                                            _currentTestimonialIndex = (_currentTestimonialIndex + 1) % _testimonials.length;
                                          });
                                          _testimonialTimer?.cancel();
                                          _startTestimonialAutoScroll();
                                        }
                                      },
                                      child: Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          color: _isHoveringNext
                                              ? AppColors.bgColor
                                              : AppColors.bgColor.withOpacity(0.2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.arrow_forward,
                                          color: _isHoveringNext ? AppColors.primaryColor : AppColors.bgColor,
                                          size: 24,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        }
                      },
                    ),
                  AppUtils().vSpace(size: 40),
                  // Divider line
                  Container(
                    height: 1,
                    width: double.infinity,
                    color: AppColors.bgColor.withOpacity(0.2),
                  ),
                  AppUtils().vSpace(size: 40),

                  // Client Logos (Placeholder - commented out until assets are available)
                  // TODO: Add client logo assets and uncomment this section
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  //   children: [
                  //     Image.asset('assets/clients/square.png', height: 40),
                  //     Image.asset('assets/clients/paperz.png', height: 40),
                  //     Image.asset('assets/clients/cuebiq.png', height: 40),
                  //     Image.asset('assets/clients/martino.png', height: 40),
                  //   ],
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
