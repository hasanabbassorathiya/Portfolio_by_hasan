import 'package:flutter/material.dart';
import 'package:portfolio/core/repositories/work_repository.dart';
import 'package:portfolio/core/repositories/testimonial_repository.dart';
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

                  // Testimonial Quote and Author (Placeholder structure)
                  SizedBox(
                    width:
                        isSmall
                            ? double.infinity
                            : 800, // Constrain width on larger screens
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.center, // Center content
                      children: [
                        if (_testimonials.isEmpty)
                          Text(
                            'No testimonials yet',
                            textAlign: TextAlign.center,
                            style: AppStyles.heading(
                              fontSize: isSmall ? 18 : 24,
                            ).copyWith(color: AppColors.bgColor),
                          )
                        else ...[
                          Text(
                            '"${_testimonials[_currentTestimonialIndex].quote}"',
                            textAlign: TextAlign.center,
                            style: AppStyles.heading(
                              fontSize: isSmall ? 18 : 24,
                            ).copyWith(
                              color: AppColors.bgColor,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          AppUtils().vSpace(size: 24),
                          Text(
                            '-${_testimonials[_currentTestimonialIndex].clientName}',
                            style: AppStyles.subheading(
                              color: AppColors.bgColor,
                              fontSize: isSmall ? 14 : 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_testimonials[_currentTestimonialIndex]
                                      .clientRole !=
                                  null ||
                              _testimonials[_currentTestimonialIndex]
                                      .clientCompany !=
                                  null)
                            Text(
                              _testimonials[_currentTestimonialIndex]
                                              .clientRole !=
                                          null &&
                                      _testimonials[_currentTestimonialIndex]
                                              .clientCompany !=
                                          null
                                  ? '${_testimonials[_currentTestimonialIndex].clientRole}, ${_testimonials[_currentTestimonialIndex].clientCompany}'
                                  : _testimonials[_currentTestimonialIndex]
                                          .clientRole ??
                                      _testimonials[_currentTestimonialIndex]
                                          .clientCompany ??
                                      '',
                              style: AppStyles.body(
                                fontSize: isSmall ? 12 : 14,
                              ).copyWith(
                                color: AppColors.bgColor.withOpacity(0.8),
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                  AppUtils().vSpace(size: 40),

                  // Navigation Buttons (Placeholder)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Back Button
                      MouseRegion(
                        onEnter: (_) {
                          setState(() {
                            _isHoveringPrev = true;
                          });
                        },
                        onExit: (_) {
                          setState(() {
                            _isHoveringPrev = false;
                          });
                        },
                        child: InkWell(
                          onTap: () {
                            if (_testimonials.isNotEmpty) {
                              setState(() {
                                _currentTestimonialIndex =
                                    (_currentTestimonialIndex - 1) %
                                    _testimonials.length;
                              });
                            }
                          },
                          child: CircleAvatar(
                            backgroundColor:
                                _isHoveringPrev
                                    ? AppColors.primaryColor.withOpacity(
                                      0.8,
                                    ) // Change color on hover
                                    : AppColors.bgColor.withOpacity(0.2),
                            child: Icon(
                              Icons.arrow_back,
                              color:
                                  _isHoveringPrev
                                      ? AppColors
                                          .bgColor // Change icon color on hover
                                      : AppColors.bgColor,
                            ), // White icon
                          ),
                        ),
                      ),
                      AppUtils().hSpace(size: 16),
                      // Forward Button
                      MouseRegion(
                        onEnter: (_) {
                          setState(() {
                            _isHoveringNext = true;
                          });
                        },
                        onExit: (_) {
                          setState(() {
                            _isHoveringNext = false;
                          });
                        },
                        child: InkWell(
                          onTap: () {
                            if (_testimonials.isNotEmpty) {
                              setState(() {
                                _currentTestimonialIndex =
                                    (_currentTestimonialIndex + 1) %
                                    _testimonials.length;
                              });
                            }
                          },
                          child: CircleAvatar(
                            backgroundColor:
                                _isHoveringNext
                                    ? AppColors
                                        .primaryColor // Change color on hover
                                    : AppColors.bgColor,
                            child: Icon(
                              Icons.arrow_forward,
                              color:
                                  _isHoveringNext
                                      ? AppColors
                                          .bgColor // Change icon color on hover
                                      : AppColors.primaryColor,
                            ), // Orange icon
                          ),
                        ),
                      ),
                    ],
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
