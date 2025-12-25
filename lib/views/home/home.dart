import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;

import 'package:portfolio/shared/constants/colors.dart';
import 'package:portfolio/shared/constants/textstyles.dart';
import 'package:portfolio/shared/constants/utils.dart';
import 'package:portfolio/shared/constants/links.dart';
import 'package:portfolio/shared/utils/link_utils.dart';

import 'package:portfolio/shared/widgets/button.dart';
import 'package:portfolio/shared/widgets/social_buttons.dart';
import 'package:portfolio/shared/widgets/profile_image_widget.dart';
import 'package:portfolio/core/services/analytics_service.dart';
import 'package:portfolio/core/repositories/profile_repository.dart';
import 'package:portfolio/core/repositories/social_link_repository.dart';
import 'package:portfolio/models/social_link/social_link_model.dart';
import 'package:portfolio/shared/utils/platform_icons.dart';

class Home extends StatefulWidget {
  final bool isActive;

  const Home({super.key, this.isActive = false});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;

  // Define new animations for text, button, and contact info
  late Animation<double> _textFadeIn;
  late Animation<Offset> _textSlide;
  late Animation<double> _ctaFadeIn;
  late Animation<Offset> _ctaSlide;
  late Animation<double> _contactFadeIn;

  bool _isHoveringPhoneNumber = false;
  bool _isHoveringEmail = false;
  final ProfileRepository _profileRepository = ProfileRepository();
  final SocialLinkRepository _socialLinkRepository = SocialLinkRepository();
  String? _phone;
  String? _title;
  List<SocialLinkModel> _socialLinks = [];

  void _trackPageView() {
    AnalyticsService.trackPageView(
      pagePath: '/',
      pageTitle: 'Home',
    );
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _profileRepository.getProfile();
      if (profile != null) {
        setState(() {
          _phone = profile.phone;
          _title = profile.title;
        });
      }
    } catch (e) {
      // Silently fail
    }
  }

  Future<void> _loadSocialLinks() async {
    try {
      final links = await _socialLinkRepository.getAllSocialLinks();
      setState(() {
        _socialLinks = links;
      });
    } catch (e) {
      // Silently fail
    }
  }

  IconData _getIconForPlatform(String platform) {
    // Try PlatformIcons first, then fallback to Iconsax
    final icon = PlatformIcons.getIcon(platform);
    if (icon != FontAwesomeIcons.link) {
      return icon;
    }
    // Fallback for Iconsax icons
    switch (platform.toLowerCase()) {
      case 'instagram':
        return Iconsax.instagram_copy;
      case 'facebook':
        return Iconsax.facebook_copy;
      default:
        return Icons.link;
    }
  }

  // Method to run animations and scroll to top when page becomes active
  void _activatePage() {
    _controller.forward(from: 0.0); // Start entry animations
  }

  @override
  void initState() {
    super.initState();
    _trackPageView();
    _loadProfile();
    _loadSocialLinks();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Existing page fade-in
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    // Define animations with intervals for staggered effect
    _textFadeIn = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.1), // Start slightly below
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );

    _ctaFadeIn = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    );
    _ctaSlide = Tween<Offset>(
      begin: const Offset(0, 0.1), // Start slightly below
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    _contactFadeIn = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  // Key for ProfileImageWidget to force refresh
  GlobalKey _profileImageKey = GlobalKey();

  @override
  void didUpdateWidget(covariant Home oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Check if the page has become active
    if (widget.isActive && !oldWidget.isActive) {
      _activatePage();
      // Refresh profile image when page becomes active
      _refreshProfileImage();
    } else if (!widget.isActive && oldWidget.isActive) {
      // Optionally reset animations when page becomes inactive
      _controller.reset();
    }
  }

  void _refreshProfileImage() {
    // Force ProfileImageWidget to reload by changing its key
    setState(() {
      _profileImageKey = GlobalKey();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.width < 768;
    final isMedium =
        MediaQuery.of(context).size.width >= 768 &&
        MediaQuery.of(context).size.width < 1280;
    final isLarge = MediaQuery.of(context).size.width >= 1280;
    debugPrint('Device width : ${MediaQuery.of(context).size.width}');

    debugPrint('isSmall : ${isSmall} isMedium: ${isMedium} isLarge:${isLarge}');

    // The main content for the Home page, to be placed inside the MainLayoutShell's body
    return FadeTransition(
      opacity: _fadeIn,
      child: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal:
                    isSmall
                        ? 20 // Increased padding for small screens
                        : isMedium
                        ? 60 // Increased padding for medium screens
                        : 100, // Increased padding for large screens
                vertical:
                    isSmall
                        ? 45
                        : 80, // Adjusted vertical padding to match Figma more closely
              ),
              child: Flex(
                direction: isSmall ? Axis.vertical : Axis.horizontal,
                mainAxisAlignment:
                    isSmall
                        ? MainAxisAlignment.start
                        : MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children:
                    isSmall
                        ? [
                          // Order for Small screens (Column)
                          // Center: Profile/Illustration - Adjust sizing for vertical layout
                          Center(
                            // Center horizontally
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                // Sizing logic for the illustration on small screens
                                // Use available constraints
                                final double availableWidth =
                                    constraints.maxWidth;
                                final double availableHeight =
                                    constraints.maxHeight;

                                // Calculate desired size, maybe cap height to prevent taking too much vertical space
                                final double desiredWidth =
                                    availableWidth *
                                    0.8; // Example: 80% of available width
                                // Cap height at a reasonable value for small screens
                                final double maxIllustrationHeight = 300.0;
                                final double desiredHeight =
                                    availableHeight < maxIllustrationHeight
                                        ? availableHeight
                                        : maxIllustrationHeight;

                                // Determine the actual size based on the smaller dimension while maintaining aspect ratio
                                // Assuming the SVG has an approximately square aspect ratio for this calculation.
                                // If the SVG has a different aspect ratio, the sizing logic might need adjustment.
                                final double actualSize = math.min(
                                  desiredWidth,
                                  desiredHeight,
                                );

                                return Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Profile Illustration Container
                                    AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 900,
                                      ),
                                      curve: Curves.easeInOut,
                                      width: actualSize, // Use calculated size
                                      height: actualSize, // Use calculated size
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(30),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.06,
                                            ),
                                            blurRadius: 32,
                                            offset: const Offset(0, 16),
                                          ),
                                        ],
                                        border: Border.all(
                                          color: AppColors.primaryColor
                                              .withOpacity(0.1),
                                          width: 2,
                                        ),
                                      ),
                                      child: ProfileImageWidget(
                                        key: _profileImageKey,
                                        fit: BoxFit.cover,
                                        width: actualSize,
                                        height: actualSize,
                                      ),
                                    ),

                                    // TODO: Add Abstract Shapes, Sparkle, and Dot Pattern here using Positioned widgets
                                    // Adjust positioning and sizes for small screens if needed
                                    // Placeholder for an abstract shape (adjust positioning and size based on Figma)
                                    Positioned(
                                      top:
                                          actualSize *
                                          0.1, // Example relative positioning
                                      right:
                                          actualSize *
                                          -0.05, // Example relative positioning
                                      child: Container(
                                        width:
                                            actualSize *
                                            0.2, // Example relative size
                                        height:
                                            actualSize *
                                            0.2, // Example relative size
                                        decoration: BoxDecoration(
                                          color: Colors.orange.withOpacity(
                                            0.5,
                                          ), // Placeholder color
                                          shape:
                                              BoxShape
                                                  .circle, // Example shape, replace with asset
                                        ),
                                        // TODO: Replace with actual abstract shape asset
                                      ),
                                    ),

                                    // Placeholder for Sparkle Icon (adjust positioning and size based on Figma)
                                    Positioned(
                                      top:
                                          actualSize *
                                          0.05, // Example relative positioning
                                      right:
                                          actualSize *
                                          0.05, // Example relative positioning
                                      child: Icon(
                                        Icons.star, // Placeholder icon
                                        color:
                                            Colors.yellow, // Placeholder color
                                        size:
                                            actualSize *
                                            0.08, // Example relative size
                                      ),
                                      // TODO: Replace with actual sparkle asset
                                    ),

                                    // Placeholder for Dot Pattern (adjust positioning and size based on Figma)
                                    Positioned(
                                      bottom:
                                          actualSize *
                                          0.05, // Example relative positioning
                                      left:
                                          actualSize *
                                          0.05, // Example relative positioning
                                      child: Container(
                                        width:
                                            actualSize *
                                            0.12, // Example relative size
                                        height:
                                            actualSize *
                                            0.12, // Example relative size
                                        color: Colors.black.withOpacity(
                                          0.2,
                                        ), // Placeholder color
                                        // TODO: Replace with actual dot pattern asset
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          const SizedBox(
                            height: 40,
                          ), // Add spacing between illustration and text
                          // Left: Text and CTA - Already wrapped in SingleChildScrollView
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Section with Name, Title, and Button
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SlideTransition(
                                    position: _textSlide,
                                    child: FadeTransition(
                                      opacity: _textFadeIn,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'MY NAME',
                                            style: AppStyles.heading(
                                              fontSize:
                                                  isSmall
                                                      ? 20
                                                      : isMedium
                                                      ? 30
                                                      : 40,
                                              fontWeight: FontWeight.bold,
                                            ).copyWith(
                                              color: AppColors.primaryColor,
                                            ),
                                          ),
                                          Text(
                                            'IS HASAN',
                                            style: AppStyles.heading(
                                              fontSize:
                                                  isSmall
                                                      ? 28
                                                      : isMedium
                                                      ? 44
                                                      : 64,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            'ABBAS',
                                            style: AppStyles.heading(
                                              fontSize:
                                                  isSmall
                                                      ? 28
                                                      : isMedium
                                                      ? 44
                                                      : 64,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            'SORATHIYA...',
                                            style: AppStyles.heading(
                                              fontSize:
                                                  isSmall
                                                      ? 28
                                                      : isMedium
                                                      ? 44
                                                      : 64,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  SlideTransition(
                                    position: _textSlide,
                                    child: FadeTransition(
                                      opacity: _textFadeIn,
                                      child: Text(
                                        _title ?? 'Software Engineer based in UAE',
                                        style: AppStyles.subheading(
                                          fontSize:
                                              isSmall
                                                  ? 14
                                                  : isMedium
                                                  ? 18
                                                  : 24,
                                          fontWeight: FontWeight.w500,
                                        ).copyWith(fontStyle: FontStyle.italic),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 30),
                                  SlideTransition(
                                    position: _ctaSlide,
                                    child: FadeTransition(
                                      opacity: _ctaFadeIn,
                                        child: AppButton(
                                        title: 'Let\'s talk with me',
                                        icons: Iconsax.arrow_right_3_copy,
                                        onTap: () {
                                          AnalyticsService.trackButtonClick(
                                            buttonName: 'Let\'s talk with me',
                                            location: 'home',
                                          );
                                          // Navigate to contact route - MainLayoutShell will handle scrolling
                                          context.go('/contact');
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 48,
                                  ), // Spacing after button
                                ],
                              ),
                              // Section with Contact Info and Social Buttons
                              FadeTransition(
                                opacity:
                                    _contactFadeIn, // Apply contact specific fade
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Contact Info (Rows)
                                    if (_phone != null && _phone!.isNotEmpty) ...[
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Iconsax.call_calling_copy,
                                            size: 18,
                                            color: AppColors.primaryColor,
                                          ),
                                          const SizedBox(width: 8),
                                          InkWell(
                                            onTap:
                                                () => LinkUtils.launchPhone(
                                                  _phone!,
                                                ),
                                            onHover: (value) {
                                              setState(() {
                                                _isHoveringPhoneNumber = value;
                                              });
                                            },
                                            child: Text(
                                              _phone!,
                                              style: AppStyles.regular(
                                                fontWeight: FontWeight.bold,
                                              ).copyWith(
                                                color:
                                                    _isHoveringPhoneNumber
                                                        ? AppColors.primaryColor
                                                        : Colors.black,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                    ],
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Iconsax.message_text_1_copy,
                                          size: 18,
                                          color: AppColors.primaryColor,
                                        ),
                                        const SizedBox(width: 8),
                                        InkWell(
                                          onTap:
                                              () => LinkUtils.launchEmail(
                                                AppLinks.email,
                                              ),
                                          onHover: (value) {
                                            setState(() {
                                              _isHoveringEmail = value;
                                            });
                                          },
                                          child: Text(
                                            AppLinks.email,
                                            style: AppStyles.regular(
                                              fontWeight: FontWeight.bold,
                                            ).copyWith(
                                              color:
                                                  _isHoveringEmail
                                                      ? AppColors.primaryColor
                                                      : Colors.black,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    // Social Buttons from admin
                                    AppUtils().vSpace(
                                      size: isSmall ? 24.0 : 32.0,
                                    ),
                                    if (_socialLinks.isNotEmpty)
                                      Wrap(
                                        spacing: 16.0,
                                        runSpacing: 16.0,
                                        children: _socialLinks.map((link) {
                                          return SocialButtons(
                                            icon: _getIconForPlatform(link.platform),
                                            link: link.url,
                                          );
                                        }).toList(),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          // Right: Socials - Excluded on small screens
                        ]
                        : [
                          // Order for Medium and Large screens (Row)
                          // Left: Text and CTA
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment:
                                isSmall
                                    ? MainAxisAlignment.start
                                    : MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Section with Name, Title, and Button
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SlideTransition(
                                    position: _textSlide,
                                    child: FadeTransition(
                                      opacity: _textFadeIn,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'MY NAME',
                                            style: AppStyles.heading(
                                              fontSize:
                                                  isSmall
                                                      ? 20
                                                      : isMedium
                                                      ? 30
                                                      : 40,
                                              fontWeight: FontWeight.bold,
                                            ).copyWith(
                                              color: AppColors.primaryColor,
                                            ),
                                          ),
                                          Text(
                                            'IS HASAN',
                                            style: AppStyles.heading(
                                              fontSize:
                                                  isSmall
                                                      ? 28
                                                      : isMedium
                                                      ? 44
                                                      : 64,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            'ABBAS',
                                            style: AppStyles.heading(
                                              fontSize:
                                                  isSmall
                                                      ? 28
                                                      : isMedium
                                                      ? 44
                                                      : 64,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            'SORATHIYA...',
                                            style: AppStyles.heading(
                                              fontSize:
                                                  isSmall
                                                      ? 28
                                                      : isMedium
                                                      ? 44
                                                      : 64,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  SlideTransition(
                                    position: _textSlide,
                                    child: FadeTransition(
                                      opacity: _textFadeIn,
                                      child: Text(
                                        _title ?? 'Software Engineer based in UAE',
                                        style: AppStyles.subheading(
                                          fontSize:
                                              isSmall
                                                  ? 14
                                                  : isMedium
                                                  ? 18
                                                  : 24,
                                          fontWeight: FontWeight.w500,
                                        ).copyWith(fontStyle: FontStyle.italic),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 30),
                                  SlideTransition(
                                    position: _ctaSlide,
                                    child: FadeTransition(
                                      opacity: _ctaFadeIn,
                                        child: AppButton(
                                        title: 'Let\'s talk with me',
                                        icons: Iconsax.arrow_right_3_copy,
                                        onTap: () {
                                          AnalyticsService.trackButtonClick(
                                            buttonName: 'Let\'s talk with me',
                                            location: 'home',
                                          );
                                          // Navigate to contact route - MainLayoutShell will handle scrolling
                                          context.go('/contact');
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 48,
                                  ), // Spacing after button
                                ],
                              ),

                              // Section with Contact Info and Social Buttons
                              FadeTransition(
                                opacity:
                                    _contactFadeIn, // Apply contact specific fade
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Contact Info (Rows)
                                    if (_phone != null && _phone!.isNotEmpty) ...[
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Iconsax.call_calling_copy,
                                            size: 18,
                                            color: AppColors.primaryColor,
                                          ),
                                          const SizedBox(width: 8),
                                          InkWell(
                                            onTap:
                                                () => LinkUtils.launchPhone(
                                                  _phone!,
                                                ),
                                            onHover: (value) {
                                              setState(() {
                                                _isHoveringPhoneNumber = value;
                                              });
                                            },
                                            child: Text(
                                              _phone!,
                                              style: AppStyles.regular(
                                                fontWeight: FontWeight.bold,
                                              ).copyWith(
                                                color:
                                                    _isHoveringPhoneNumber
                                                        ? AppColors.primaryColor
                                                        : Colors.black,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                    ],
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Iconsax.message_text_1_copy,
                                          size: 18,
                                          color: AppColors.primaryColor,
                                        ),
                                        const SizedBox(width: 8),
                                        InkWell(
                                          onTap:
                                              () => LinkUtils.launchEmail(
                                                AppLinks.email,
                                              ),
                                          onHover: (value) {
                                            setState(() {
                                              _isHoveringEmail = value;
                                            });
                                          },
                                          child: Text(
                                            AppLinks.email,
                                            style: AppStyles.regular(
                                              fontWeight: FontWeight.bold,
                                            ).copyWith(
                                              color:
                                                  _isHoveringEmail
                                                      ? AppColors.primaryColor
                                                      : Colors.black,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    // Social Buttons from admin
                                    AppUtils().vSpace(
                                      size: isSmall ? 24.0 : 32.0,
                                    ),
                                    if (_socialLinks.isNotEmpty)
                                      Wrap(
                                        spacing: 16.0,
                                        runSpacing: 16.0,
                                        children: _socialLinks.map((link) {
                                          return SocialButtons(
                                            icon: _getIconForPlatform(link.platform),
                                            link: link.url,
                                          );
                                        }).toList(),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          // Center: Profile/Illustration
                          Expanded(
                            flex: isMedium ? 4 : 4,
                            child: Center(
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  final double maxIllustrationWidth =
                                      isMedium ? 300 : 400;
                                  final double maxIllustrationHeight =
                                      isMedium ? 380 : 500;

                                  // Calculate available width and height
                                  final double availableWidth =
                                      constraints.maxWidth;
                                  final double availableHeight =
                                      constraints.maxHeight;

                                  // Determine the actual size, scaling down if necessary
                                  final double actualWidth =
                                      availableWidth < maxIllustrationWidth
                                          ? availableWidth
                                          : maxIllustrationWidth;
                                  final double actualHeight =
                                      availableHeight < maxIllustrationHeight
                                          ? availableHeight
                                          : maxIllustrationHeight;

                                  // Also scale the SVG down proportionally within the container
                                  final double avatarWidth =
                                      isMedium ? 220 : 320;
                                  final double avatarHeight =
                                      isMedium ? 320 : 440;

                                  final double actualAvatarWidth =
                                      availableWidth < avatarWidth
                                          ? availableWidth *
                                              (avatarWidth /
                                                  maxIllustrationWidth)
                                          : avatarWidth;
                                  final double actualAvatarHeight =
                                      availableHeight < avatarHeight
                                          ? availableHeight *
                                              (avatarHeight /
                                                  maxIllustrationHeight)
                                          : avatarHeight;

                                  return Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // Profile Illustration Container
                                      AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 900,
                                        ),
                                        curve: Curves.easeInOut,
                                        width:
                                            actualWidth, // Use calculated width
                                        height:
                                            actualHeight, // Use calculated height
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.06,
                                              ),
                                              blurRadius: 32,
                                              offset: const Offset(0, 16),
                                            ),
                                          ],
                                          border: Border.all(
                                            color: AppColors.primaryColor
                                                .withOpacity(0.1),
                                            width: 2,
                                          ),
                                        ),
                                        child: ProfileImageWidget(
                                          key: _profileImageKey,
                                          width: actualAvatarWidth,
                                          height: actualAvatarHeight,
                                          fit: BoxFit.cover,
                                        ),
                                      ),

                                      // TODO: Add Abstract Shapes, Sparkle, and Dot Pattern here using Positioned widgets
                                      // Placeholder for an abstract shape (adjust positioning and size based on Figma)
                                      Positioned(
                                        top: isMedium ? 40 : 50,
                                        right: isMedium ? -10 : -20,
                                        child: Container(
                                          width: isMedium ? 80 : 100,
                                          height: isMedium ? 80 : 100,
                                          decoration: BoxDecoration(
                                            color: Colors.orange.withOpacity(
                                              0.5,
                                            ),
                                            shape: BoxShape.circle,
                                          ), // TODO: Replace with actual abstract shape asset
                                        ),
                                      ),

                                      // Placeholder for Sparkle Icon (adjust positioning and size based on Figma)
                                      Positioned(
                                        top: isMedium ? 15 : 20,
                                        right: isMedium ? 15 : 20,
                                        child: Icon(
                                          Icons.star,
                                          color: Colors.yellow,
                                          size: isMedium ? 25 : 30,
                                        ), // TODO: Replace with actual sparkle asset
                                      ),

                                      // Placeholder for Dot Pattern (adjust positioning and size based on Figma)
                                      Positioned(
                                        bottom: isMedium ? 15 : 20,
                                        left: isMedium ? 15 : 20,
                                        child: Container(
                                          width: isMedium ? 40 : 50,
                                          height: isMedium ? 40 : 50,
                                          color: Colors.black.withOpacity(
                                            0.2,
                                          ), // TODO: Replace with actual dot pattern asset
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                          // Right: Socials
                          Expanded(
                            flex: isSmall ? 1 : (isMedium ? 1 : 1),
                            child: Align(
                              alignment:
                                  isSmall
                                      ? Alignment.center
                                      : Alignment.centerRight,
                              child: Column(
                                mainAxisAlignment:
                                    isSmall
                                        ? MainAxisAlignment.start
                                        : MainAxisAlignment.center,
                                crossAxisAlignment:
                                    isSmall
                                        ? CrossAxisAlignment.center
                                        : CrossAxisAlignment.end,
                                children: [
                                  // Social buttons from admin
                                  if (_socialLinks.isNotEmpty)
                                    ..._socialLinks.map((link) {
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 12),
                                        child: SocialButtons(
                                          icon: _getIconForPlatform(link.platform),
                                          link: link.url,
                                        ),
                                      );
                                    }).toList(),
                                  const SizedBox(height: 12),
                                  if (!isSmall)
                                    SizedBox(
                                      width: 18,
                                      child: Divider(
                                        thickness: 1,
                                        color: AppColors.primaryColor,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
              ),
            );
          },
        ),
      ),
    );
  }
}
