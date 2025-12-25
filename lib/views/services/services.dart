import 'package:flutter/material.dart';
import 'package:portfolio/core/repositories/service_repository.dart';
import 'package:portfolio/models/service/service_model.dart';
import 'package:portfolio/shared/constants/colors.dart';
import 'package:portfolio/shared/constants/textstyles.dart';
import 'package:portfolio/shared/constants/utils.dart';
import 'package:portfolio/shared/widgets/gradient_text.dart';
import 'package:portfolio/shared/widgets/empty_state.dart';
import 'package:portfolio/core/services/analytics_service.dart';

class Services extends StatefulWidget {
  final bool isActive;

  const Services({super.key, this.isActive = false});

  @override
  State<Services> createState() => _ServicesState();
}

class _ServicesState extends State<Services>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  final ServiceRepository _serviceRepository = ServiceRepository();
  List<ServiceModel> _services = [];
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
    _loadServices();
  }

  void _trackPageView() {
    AnalyticsService.trackPageView(
      pagePath: '/services',
      pageTitle: 'Services',
    );
  }

  Future<void> _loadServices() async {
    try {
      setState(() => _isLoading = true);
      final services = await _serviceRepository.getActiveServices();
      setState(() {
        _services = services;
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
  void didUpdateWidget(covariant Services oldWidget) {
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
            Text('SERVICE', style: AppStyles.subheading(fontSize: 18)),
            AppUtils().vSpace(size: 12),
            Text(
              'MY SPECIALTIES'.toUpperCase(),
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
            else if (_services.isEmpty)
              EmptyState(
                title: 'No Services Yet',
                message: 'Services will appear here once added from the admin panel.',
                icon: Icons.build_outlined,
              )
            else
              ..._buildServicesList(context, isSmall, isMedium),
            AppUtils().vSpace(size: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileAppServiceItem(
    BuildContext context,
    bool isSmall,
    bool isMedium,
    String title,
    String description,
    String imageAsset,
    int index,
    int? expandedIndex,
    Function(int) toggleExpanded,
  ) {
    final bool isExpanded = index == expandedIndex;
    final bool isHovered = index == _hoveredIndex;

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
          color:
              isHovered
                  ? AppColors.primaryColor.withOpacity(0.1)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= 700) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GradientText(
                    '• ',
                    gradient: AppUtils().appGradient,
                    style: AppStyles.heading(
                      fontSize: isSmall ? 24 : 28,
                      fontWeight: FontWeight.bold,
                      color:
                          isExpanded || isHovered
                              ? AppColors.primaryColor
                              : Colors.black,
                    ),
                  ),
                  SizedBox(width: 8),
                  (isExpanded || isHovered)
                      ? GradientText(
                        title,
                        gradient: AppUtils().appGradient,
                        style: AppStyles.heading(
                          fontSize: isSmall ? 24 : 28,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                      : Text(
                        title,
                        style: AppStyles.heading(
                          fontSize: isSmall ? 24 : 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                  SizedBox(width: 8),
                  AnimatedRotation(
                    turns: isExpanded ? 0.25 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      isExpanded ? Icons.remove : Icons.add,
                      size: 24,
                      color: Colors.black,
                    ),
                  ),
                  if (isExpanded && constraints.maxWidth >= 700) ...[
                    SizedBox(width: 16),
                    imageAsset.startsWith('http://') || imageAsset.startsWith('https://')
                        ? Image.network(
                            imageAsset,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const SizedBox.shrink();
                            },
                          )
                        : Image.asset(imageAsset, fit: BoxFit.contain),
                  ],
                ],
              );
            } else {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GradientText(
                        '• ',
                        gradient: AppUtils().appGradient,
                        style: AppStyles.heading(
                          fontSize: isSmall ? 24 : 28,
                          fontWeight: FontWeight.bold,
                          color:
                              isExpanded || isHovered
                                  ? AppColors.primaryColor
                                  : Colors.black,
                        ),
                      ),
                      Expanded(
                        child:
                            isExpanded || isHovered
                                ? GradientText(
                                  title,
                                  gradient: AppUtils().appGradient,
                                  style: AppStyles.heading(
                                    fontSize: isSmall ? 24 : 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                                : Text(
                                  title,
                                  style: AppStyles.heading(
                                    fontSize: isSmall ? 24 : 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
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
                  if (isExpanded) ...[
                    AppUtils().vSpace(size: 12),
                    Padding(
                      padding: const EdgeInsets.only(left: 24.0),
                      child: Text(
                        description,
                        style: AppStyles.body(fontSize: isSmall ? 14 : 16),
                      ),
                    ),
                    AppUtils().vSpace(size: 20),
                    imageAsset.startsWith('http://') || imageAsset.startsWith('https://')
                        ? Image.network(
                            imageAsset,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const SizedBox.shrink();
                            },
                          )
                        : Image.asset(imageAsset, fit: BoxFit.contain),
                  ],
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildServiceItem(
    BuildContext context,
    bool isSmall,
    bool isMedium,
    String title,
    String description,
    int index,
    int? expandedIndex,
    Function(int) toggleExpanded,
  ) {
    final bool isExpanded = index == expandedIndex;
    final bool isHovered = index == _hoveredIndex;

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
          color:
              isHovered
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
                Text(
                  '• ',
                  style: AppStyles.heading(
                    fontSize: isSmall ? 24 : 28,
                    fontWeight: FontWeight.bold,
                    color:
                        isExpanded || isHovered
                            ? AppColors.primaryColor
                            : Colors.black,
                  ),
                ),
                Expanded(
                  child: Text(
                    title,
                    style: AppStyles.heading(
                      fontSize: isSmall ? 24 : 28,
                      fontWeight: FontWeight.bold,
                      color:
                          isExpanded || isHovered
                              ? AppColors.primaryColor
                              : Colors.black,
                    ),
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
            if (isExpanded) ...[
              AppUtils().vSpace(size: 12),
              Padding(
                padding: const EdgeInsets.only(left: 24.0),
                child: Text(
                  description,
                  style: AppStyles.body(fontSize: isSmall ? 14 : 16),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _buildServicesList(
    BuildContext context,
    bool isSmall,
    bool isMedium,
  ) {
    final List<Widget> widgets = [];
    for (int i = 0; i < _services.length; i++) {
      final service = _services[i];
      final hasImage = service.iconUrl != null && service.iconUrl!.isNotEmpty;
      
      if (hasImage && service.iconUrl!.contains('mobile')) {
        widgets.add(
          _buildMobileAppServiceItem(
            context,
            isSmall,
            isMedium,
            service.title.toUpperCase(),
            service.description ?? 'No description available.',
            service.iconUrl!,
            i,
            _expandedIndex,
            _toggleExpanded,
          ),
        );
      } else {
        widgets.add(
          _buildServiceItem(
            context,
            isSmall,
            isMedium,
            service.title.toUpperCase(),
            service.description ?? 'No description available.',
            i,
            _expandedIndex,
            _toggleExpanded,
          ),
        );
      }
      
      if (i < _services.length - 1) {
        widgets.add(AppUtils().vSpace(size: 20));
        widgets.add(const Divider());
        widgets.add(AppUtils().vSpace(size: 20));
      }
    }
    return widgets;
  }
}
