import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:portfolio/core/repositories/experience_repository.dart';
import 'package:portfolio/shared/constants/assets.dart';
import 'package:portfolio/shared/constants/colors.dart';
import 'package:portfolio/shared/constants/textstyles.dart';
import 'package:portfolio/shared/constants/utils.dart';
import 'package:portfolio/shared/widgets/button.dart';
import 'package:portfolio/shared/widgets/experience_card.dart';
import 'package:portfolio/shared/widgets/gradient_text.dart';
import 'package:portfolio/shared/widgets/empty_state.dart';
import 'package:portfolio/shared/utils/link_utils.dart';
import 'package:portfolio/shared/constants/links.dart';
import 'package:portfolio/core/services/analytics_service.dart';

class About extends StatefulWidget {
  final bool isActive;

  const About({super.key, this.isActive = false});

  @override
  State<About> createState() => _AboutState();
}

class _AboutState extends State<About> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  final ExperienceRepository _experienceRepository = ExperienceRepository();
  List<ExperienceModel> _experiences = [];
  bool _isLoadingExperiences = true;

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
      pagePath: '/about',
      pageTitle: 'About',
    );
  }

  Future<void> _loadExperiences() async {
    try {
      final experiences = await _experienceRepository.getAllExperiences();
      setState(() {
        _experiences = experiences;
        _isLoadingExperiences = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingExperiences = false;
      });
    }
  }

  void _activatePage() {
    _animationController.forward(from: 0.0);
  }

  @override
  void didUpdateWidget(covariant About oldWidget) {
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
            _buildIntroAndInfo(context, isSmall, isMedium),
            AppUtils().vSpace(size: isSmall ? 40.0 : 80.0),
            _buildExperienceAndClients(context, isSmall, isMedium),
            AppUtils().vSpace(size: isSmall ? 40.0 : 80.0),
            _buildQuoteSection(context, isSmall, isMedium),
            AppUtils().vSpace(size: isSmall ? 40.0 : 80.0),
            _buildBottomExperienceCards(context, isSmall, isMedium),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroAndInfo(BuildContext context, bool isSmall, bool isMedium) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 700) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nice to meet you!',
                      style: AppStyles.subheading(
                        color: AppColors.primaryColor,
                      ).copyWith(
                        fontSize:
                            isSmall
                                ? 16
                                : isMedium
                                ? 20
                                : 24,
                      ),
                    ),
                    AppUtils().vSpace(
                      size:
                          isSmall
                              ? 10.0
                              : isMedium
                              ? 15.0
                              : 20.0,
                    ),
                    Text(
                      'Welcome to...',
                      style: AppStyles.heading(
                        color: AppColors.primaryColor,
                        fontSize: isSmall ? 36 : 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    AppUtils().vSpace(size: isSmall ? 24.0 : 40.0),
                    Image.asset(
                      AppAssets.user,
                      width:
                          isSmall
                              ? 180.0
                              : isMedium
                              ? 220.0
                              : 260.0,
                      height:
                          isSmall
                              ? 180.0
                              : isMedium
                              ? 220.0
                              : 260.0,
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
              ),
              SizedBox(width: isSmall ? 40.0 : 80.0),
              Flexible(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GradientText(
                      'HASAN ABBAS SORATHIYA',
                      style: AppStyles.heading(
                        color: AppColors.primaryColor,
                        fontSize:
                            isSmall
                                ? 28.0
                                : isMedium
                                ? 36.0
                                : 44.0,
                        fontWeight: FontWeight.bold,
                      ),
                      gradient: AppUtils().appGradient,
                    ),
                    AppUtils().vSpace(size: isSmall ? 12.0 : 16.0),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Software Engineer'.toUpperCase(),
                            style: AppStyles.heading(
                              fontSize:
                                  isSmall
                                      ? 16.0
                                      : isMedium
                                      ? 20.0
                                      : 24.0,
                              fontWeight: FontWeight.bold,
                            ).copyWith(fontStyle: FontStyle.italic),
                          ),
                          TextSpan(
                            text: ' based in '.toUpperCase(),
                            style: AppStyles.heading(
                              fontSize:
                                  isSmall
                                      ? 16.0
                                      : isMedium
                                      ? 20.0
                                      : 24.0,
                            ),
                          ),
                          TextSpan(
                            text: 'UAE'.toUpperCase(),
                            style: AppStyles.heading(
                              fontSize:
                                  isSmall
                                      ? 16.0
                                      : isMedium
                                      ? 20.0
                                      : 24.0,
                              fontWeight: FontWeight.bold,
                            ).copyWith(fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                    ),
                    AppUtils().vSpace(size: isSmall ? 32.0 : 48.0),
                    AppButton(
                      title: 'Download CV 	',
                      icons: Iconsax.arrow_right_3_copy,
                      onTap: () => LinkUtils.launchUrl(AppLinks.cvLink),
                    ),
                    AppUtils().vSpace(size: isSmall ? 30.0 : 40.0),
                    _buildContactInfo(context, isSmall, isMedium),
                  ],
                ),
              ),
            ],
          );
        } else {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nice to meet you!',
                style: AppStyles.subheading(
                  color: AppColors.primaryColor,
                ).copyWith(fontSize: isSmall ? 16.0 : 24.0),
              ),
              AppUtils().vSpace(size: isSmall ? 10.0 : 20.0),
              Text(
                'Welcome to...',
                style: AppStyles.heading(
                  color: AppColors.primaryColor,
                  fontSize: isSmall ? 36.0 : 48.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              AppUtils().vSpace(size: isSmall ? 20.0 : 40.0),
              Align(
                alignment: isSmall ? Alignment.center : Alignment.topLeft,
                child: Image.asset(
                  AppAssets.user,
                  width: isSmall ? 180.0 : 260.0,
                  height: isSmall ? 180.0 : 260.0,
                  fit: BoxFit.cover,
                ),
              ),
              AppUtils().vSpace(size: isSmall ? 24.0 : 32.0),
              GradientText(
                'HASAN ABBAS SORATHIYA',
                style: AppStyles.heading(
                  color: AppColors.primaryColor,
                  fontSize: isSmall ? 28.0 : 44.0,
                  fontWeight: FontWeight.bold,
                ),
                gradient: AppUtils().appGradient,
              ),
              AppUtils().vSpace(size: isSmall ? 8.0 : 12.0),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Software Engineer'.toUpperCase(),
                      style: AppStyles.heading(
                        fontSize: isSmall ? 16.0 : 24.0,
                        fontWeight: FontWeight.bold,
                      ).copyWith(fontStyle: FontStyle.italic),
                    ),
                    TextSpan(
                      text: ' based in '.toUpperCase(),
                      style: AppStyles.heading(fontSize: isSmall ? 16.0 : 24.0),
                    ),
                    TextSpan(
                      text: 'UAE'.toUpperCase(),
                      style: AppStyles.heading(
                        fontSize: isSmall ? 16.0 : 24.0,
                        fontWeight: FontWeight.bold,
                      ).copyWith(fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
              AppUtils().vSpace(size: isSmall ? 24.0 : 32.0),
              AppButton(
                title: 'Download CV 	',
                icons: Iconsax.arrow_right_3_copy,
                onTap: () => LinkUtils.launchUrl(AppLinks.cvLink),
              ),
              AppUtils().vSpace(size: isSmall ? 30.0 : 40.0),
              _buildContactInfo(context, isSmall, isMedium),
            ],
          );
        }
      },
    );
  }

  Widget _buildContactInfo(BuildContext context, bool isSmall, bool isMedium) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Iconsax.call_calling_copy,
              size: 20,
              color: AppColors.primaryColor,
            ),
            const SizedBox(width: 12.0),
            InkWell(
              onTap: () => LinkUtils.launchPhone(AppLinks.phoneNumber),
              child: Text(
                AppLinks.phoneNumber,
                style: AppStyles.regular(
                  fontWeight: FontWeight.bold,
                  fontSize: isSmall ? 15 : 18.0,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16.0),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Iconsax.message_text_1_copy,
              size: 20,
              color: AppColors.primaryColor,
            ),
            const SizedBox(width: 12.0),
            InkWell(
              onTap: () => LinkUtils.launchEmail(AppLinks.email),
              child: Text(
                AppLinks.email,
                style: AppStyles.regular(
                  fontWeight: FontWeight.bold,
                  fontSize: isSmall ? 15 : 18.0,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16.0),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Iconsax.user_cirlce_add_copy,
              size: 20, // Adjusted icon size
              color: AppColors.primaryColor,
            ),
            const SizedBox(width: 12.0), // Adjusted spacing
            Text(
              '25 Years', // Age from Figma
              style: AppStyles.regular(
                // Using regular style with bold
                fontWeight: FontWeight.bold,
                fontSize: isSmall ? 15 : 18.0, // Adjusted font size
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
        const SizedBox(height: 16.0), // Adjusted spacing
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Iconsax.location_add_copy,
              size: 20, // Adjusted icon size
              color: AppColors.primaryColor,
            ),
            const SizedBox(width: 12.0), // Adjusted spacing
            Text(
              'Dubai, UAE', // Location from Figma
              style: AppStyles.regular(
                // Using regular style with bold
                fontWeight: FontWeight.bold,
                fontSize: isSmall ? 15 : 18.0, // Adjusted font size
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ],
    );
  }

  // Extracted method for Experience and Clients Section (reused)
  Widget _buildExperienceAndClients(
    BuildContext context,
    bool isSmall,
    bool isMedium,
  ) {
    bool isVerticalLayout = isSmall || isMedium;
    return Flex(
      direction: isVerticalLayout ? Axis.vertical : Axis.horizontal,
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // First Column (Years Experience)
        Flexible(
          flex: 1,
          fit: FlexFit.loose,
          child:
              isVerticalLayout
                  ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GradientText(
                            '6+\t',
                            gradient: AppUtils().appGradient,
                            style: AppStyles.heading(
                              fontSize: isSmall ? 40.0 : 60.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 16.0),
                          Flexible(
                            child: Text(
                              'Years Experience',
                              style: AppStyles.subheading(
                                fontWeight: FontWeight.bold,
                                fontSize: isSmall ? 20.0 : 28.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                      AppUtils().vSpace(size: isSmall ? 12.0 : 16.0),
                      Text(
                        'Hello there! My name is Hasan Abbas Sorathiya. I am a web designer & developer, and I\'m very passionate and dedicated to my work.',
                        softWrap: true,
                        style: AppStyles.body(fontSize: isSmall ? 16.0 : 20.0),
                      ),
                    ],
                  )
                  : Text(
                    'Hello there! My name is Hasan Abbas Sorathiya. I am a web designer & developer, and I\'m very passionate and dedicated to my work.',
                    softWrap: true,
                    style: AppStyles.body(fontSize: isSmall ? 16.0 : 20.0),
                  ),
        ),

        // Spacing between columns/sections
        SizedBox(
          width: isVerticalLayout ? 0.0 : 60.0,
          height: isVerticalLayout ? 40.0 : 0.0,
        ),

        // Second Column (Clients Worldwide)
        Flexible(
          flex: 1,
          fit: FlexFit.loose,
          child:
              isVerticalLayout
                  ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GradientText(
                            '14+\t',
                            gradient: AppUtils().appGradient,
                            style: AppStyles.heading(
                              fontSize: isSmall ? 40.0 : 60.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 16.0),
                          Flexible(
                            child: Text(
                              'Clients Worldwide',
                              style: AppStyles.subheading(
                                fontWeight: FontWeight.bold,
                                fontSize: isSmall ? 20.0 : 28.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                      AppUtils().vSpace(size: isSmall ? 12.0 : 16.0),
                      Text(
                        'With 10+ years experience as a professional a graphic designer, I have acquired the skills and knowledge necessary to make your project a success.',
                        softWrap: true,
                        style: AppStyles.body(fontSize: isSmall ? 16.0 : 20.0),
                      ),
                    ],
                  )
                  : Text(
                    'With 10+ years experience as a professional a graphic designer, I have acquired the skills and knowledge necessary to make your project a success.',
                    softWrap: true,
                    style: AppStyles.body(fontSize: isSmall ? 16.0 : 20.0),
                  ),
        ),
      ],
    );
  }

  // Extracted method for Quote Section (reused)
  Widget _buildQuoteSection(BuildContext context, bool isSmall, bool isMedium) {
    return Center(
      // Center the quote section horizontally
      child: Container(
        constraints: BoxConstraints(
          maxWidth:
              isSmall
                  ? double.infinity
                  : 800.0, // Limit width on larger screens
        ),
        padding: EdgeInsets.all(
          isSmall ? 24.0 : 32.0, // Adjusted padding based on Figma
        ),
        decoration: BoxDecoration(
          gradient: AppUtils().appGradient,
        ), // Keep gradient
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // Use min to wrap content
          children: [
            const Icon(
              Icons.format_quote_outlined,
              color: AppColors.bgColor,
              size: 32,
            ), // Adjusted icon size
            SizedBox(width: isSmall ? 12.0 : 20.0), // Adjusted spacing
            Flexible(
              // Use Flexible to allow text to take available space but shrink if needed
              child: Text(
                "“Lorem ipsum dolor sit amet, consectetur adipiscing elit. Faucibus sed sit ultrices et sed metus sollicitudin.”", // Verify text content
                softWrap: true,
                style: AppStyles.subheading(
                  // Using subheading style
                  color: AppColors.bgColor, // White text
                  fontSize: isSmall ? 18.0 : 24.0, // Adjusted font size
                ).copyWith(fontStyle: FontStyle.italic), // Italic style
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Extracted method for Bottom Experience Cards Section (reused)
  Widget _buildBottomExperienceCards(
    BuildContext context,
    bool isSmall,
    bool isMedium,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 24.0 : 100.0, // Adjusted padding
        vertical: isSmall ? 40.0 : 80.0, // Adjusted padding
      ),
      decoration: BoxDecoration(
        gradient: AppUtils().appGradient,
      ), // Keep gradient
      child: Flex(
        direction: isSmall || isMedium ? Axis.vertical : Axis.horizontal,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment:
            CrossAxisAlignment.start, // Align items to the start vertically
        children: [
          Flexible(
            flex: isSmall || isMedium ? 0 : 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Experience',
                  style: AppStyles.subheading(
                    color: AppColors.bgColor,
                  ).copyWith(
                    fontSize: isSmall ? 18.0 : 24.0,
                  ), // Adjusted font size
                ),
                AppUtils().vSpace(
                  size: isSmall ? 12.0 : 16.0, // Adjusted spacing
                ),
                Text(
                  'My experience'.toUpperCase(),
                  style: AppStyles.heading(
                    color: AppColors.bgColor,
                    fontSize: isSmall ? 36.0 : 48.0, // Adjusted font size
                    fontWeight: FontWeight.bold,
                  ),
                ),
                AppUtils().vSpace(
                  size: isSmall ? 16.0 : 20.0, // Adjusted spacing
                ),
                Text(
                  'Hello there! My name is Hasan Abbas Sorathiya.I am a web designer & developer, and I\'m very passionate and dedicated to my work.', // Verify text
                  softWrap: true,
                  style: AppStyles.body(
                    color: AppColors.bgColor, // White text
                    fontSize: isSmall ? 16.0 : 20.0, // Adjusted font size
                  ),
                ),
                AppUtils().vSpace(
                  size: isSmall ? 24.0 : 32.0, // Adjusted spacing before button
                ),
                AppButton(
                  title: 'Download my resume', // Removed extra space
                  icons: Iconsax.arrow_right_3_copy,
                  onTap: () => LinkUtils.launchUrl(AppLinks.resumeLink),
                ),
              ],
            ),
          ),
          SizedBox(
            width:
                isSmall || isMedium
                    ? 0.0
                    : 60.0, // Adjusted spacing between columns
            height:
                isSmall || isMedium
                    ? 40.0
                    : 0.0, // Adjusted spacing between columns
          ),
          Flexible(
            flex: isSmall || isMedium ? 0 : 1,
            child:
                _isLoadingExperiences
                    ? const Center(child: CircularProgressIndicator())
                    : _experiences.isEmpty
                    ? EmptyState(
                      title: 'No Experience Yet',
                      message: 'Work experience will appear here!',
                      icon: Icons.work_outline,
                    )
                    : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                          _experiences.map<Widget>((exp) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 24.0),
                              child: ExperienceCard(
                                key: ValueKey(exp.id),
                                title: exp.position,
                                experience:
                                    exp.description != null
                                        ? [exp.description!]
                                        : const [],
                                designation: exp.position,
                                company: exp.company,
                                startDate: exp.startDate,
                                endDate:
                                    exp.endDate ??
                                    (exp.isCurrent
                                        ? DateTime.now()
                                        : exp.startDate),
                              ),
                            );
                          }).toList(),
                    ),
          ),
        ],
      ),
    );
  }
}
