import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;

import 'package:portfolio/shared/constants/colors.dart';
import 'package:portfolio/shared/constants/textstyles.dart';
import 'package:portfolio/shared/constants/utils.dart';
import 'package:portfolio/shared/constants/links.dart';
import 'package:portfolio/shared/routes/app_routes.dart';
import 'package:portfolio/shared/utils/link_utils.dart';

import 'package:portfolio/shared/widgets/button.dart';
import 'package:portfolio/shared/widgets/social_buttons.dart';
import 'package:portfolio/shared/widgets/profile_image_widget.dart';
import 'package:portfolio/shared/widgets/typewriter_text.dart';
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
  String? _bio;
  String? _resumeUrl;
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
          _bio = profile.bio;
          _resumeUrl = profile.resumeUrl;
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

  dynamic _getIconForPlatform(String platform) {
    // Try PlatformIcons first, then fallback to default
    final icon = PlatformIcons.getIcon(platform);
    return icon;
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
  // Key for TypewriterText to restart animation
  GlobalKey _typewriterKey = GlobalKey();

  @override
  void didUpdateWidget(covariant Home oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Check if the page has become active
    if (widget.isActive && !oldWidget.isActive) {
      _activatePage();
      // Refresh profile image when page becomes active
      _refreshProfileImage();
      // Restart typewriter animation
      setState(() {
        _typewriterKey = GlobalKey();
      });
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

  List<Widget> _buildSmallChildren() {
    return [
      Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double availableWidth = constraints.maxWidth;
            final double availableHeight = constraints.maxHeight;
            final double desiredWidth = availableWidth * 0.8;
            final double maxIllustrationHeight = 300.0;
            final double desiredHeight =
                availableHeight < maxIllustrationHeight
                    ? availableHeight
                    : maxIllustrationHeight;
            final double actualSize = math.min(desiredWidth, desiredHeight);
            return Stack(
              alignment: Alignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeInOut,
                  width: actualSize,
                  height: actualSize,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 32,
                        offset: const Offset(0, 16),
                      ),
                    ],
                    border: Border.all(
                      color: AppColors.primaryColor.withOpacity(0.1),
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
                Positioned(
                  top: actualSize * 0.1,
                  right: actualSize * -0.05,
                  child: Container(
                    width: actualSize * 0.2,
                    height: actualSize * 0.2,
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  top: actualSize * 0.05,
                  right: actualSize * 0.05,
                  child: Icon(
                    Icons.star,
                    color: Colors.yellow,
                    size: actualSize * 0.08,
                  ),
                ),
                Positioned(
                  bottom: actualSize * 0.05,
                  left: actualSize * 0.05,
                  child: Container(
                    width: actualSize * 0.12,
                    height: actualSize * 0.12,
                    color: Colors.black.withOpacity(0.2),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      const SizedBox(height: 40),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SlideTransition(
                position: _textSlide,
                child: FadeTransition(
                  opacity: _textFadeIn,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MY NAME',
                        style: AppStyles.heading(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ).copyWith(color: AppColors.primaryColor),
                      ),
                      Text(
                        'IS HASAN',
                        style: AppStyles.heading(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'ABBAS',
                        style: AppStyles.heading(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'SORATHIYA...',
                        style: AppStyles.heading(
                          fontSize: 28,
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
                  child: _bio != null && _bio!.isNotEmpty
                      ? TypewriterText(
                          key: _typewriterKey,
                          text: _bio!,
                          style: AppStyles.subheading(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ).copyWith(fontStyle: FontStyle.italic),
                          speed: const Duration(milliseconds: 30),
                        )
                      : Text(
                          _title ?? 'Software Engineer based in UAE',
                          style: AppStyles.subheading(
                            fontSize: 14,
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
                    title: 'Resume',
                    icons: Iconsax.arrow_right_3_copy,
                    onTap: () {
                      AnalyticsService.trackDownload(
                        fileType: 'pdf',
                        fileName: 'Resume',
                      );
                      LinkUtils.launchUrl(
                        _resumeUrl ?? AppLinks.cvLink,
                        linkType: 'cv_download',
                        linkName: 'Resume',
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 48),
              FadeTransition(
                opacity: _contactFadeIn,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                            onTap: () => LinkUtils.launchPhone(_phone!),
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
                                color: _isHoveringPhoneNumber
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
                        Flexible(
                          child: InkWell(
                            onTap: () => LinkUtils.launchEmail(AppLinks.email),
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
                                color: _isHoveringEmail
                                    ? AppColors.primaryColor
                                    : Colors.black,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                    AppUtils().vSpace(size: 24.0),
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
        ],
      ),
    ];
  }

  List<Widget> _buildLargeChildren() {
    return [
      Expanded(
        flex: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SlideTransition(
                  position: _textSlide,
                  child: FadeTransition(
                    opacity: _textFadeIn,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MY NAME',
                          style: AppStyles.heading(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ).copyWith(color: AppColors.primaryColor),
                        ),
                        Text(
                          'IS HASAN',
                          style: AppStyles.heading(
                            fontSize: 44,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'ABBAS',
                          style: AppStyles.heading(
                            fontSize: 44,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'SORATHIYA...',
                          style: AppStyles.heading(
                            fontSize: 44,
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
                    child: _bio != null && _bio!.isNotEmpty
                        ? TypewriterText(
                            key: _typewriterKey,
                            text: _bio!,
                            style: AppStyles.subheading(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ).copyWith(fontStyle: FontStyle.italic),
                            speed: const Duration(milliseconds: 30),
                          )
                        : Text(
                            _title ?? 'Software Engineer based in UAE',
                            style: AppStyles.subheading(
                              fontSize: 18,
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
                      title: 'Get in Touch',
                      icons: Iconsax.arrow_right_3_copy,
                      onTap: () {
                        AnalyticsService.trackButtonClick(
                          buttonName: 'Let\'s talk with me',
                          location: 'home',
                        );
                        context.goNamed(AppRoutes.contact);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 48),
              ],
            ),
            FadeTransition(
              opacity: _contactFadeIn,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                          onTap: () => LinkUtils.launchPhone(_phone!),
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
                              color: _isHoveringPhoneNumber
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
                      Flexible(
                        child: InkWell(
                          onTap: () => LinkUtils.launchEmail(AppLinks.email),
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
                              color: _isHoveringEmail
                                  ? AppColors.primaryColor
                                  : Colors.black,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                  AppUtils().vSpace(size: 32.0),
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
      ),
      Expanded(
        flex: 4,
        child: Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double maxIllustrationWidth = 400.0;
              final double maxIllustrationHeight = 500.0;
              final double availableWidth = constraints.maxWidth;
              final double availableHeight = constraints.maxHeight;
              final double actualWidth =
                  availableWidth < maxIllustrationWidth
                      ? availableWidth
                      : maxIllustrationWidth;
              final double actualHeight =
                  availableHeight < maxIllustrationHeight
                      ? availableHeight
                      : maxIllustrationHeight;
              final double avatarWidth = 320.0;
              final double avatarHeight = 440.0;
              final double actualAvatarWidth =
                  availableWidth < avatarWidth
                      ? availableWidth * (avatarWidth / maxIllustrationWidth)
                      : avatarWidth;
              final double actualAvatarHeight =
                  availableHeight < avatarHeight
                      ? availableHeight * (avatarHeight / maxIllustrationHeight)
                      : avatarHeight;

              return Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.easeInOut,
                    width: actualWidth,
                    height: actualHeight,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 32,
                          offset: const Offset(0, 16),
                        ),
                      ],
                      border: Border.all(
                        color: AppColors.primaryColor.withOpacity(0.1),
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
                  Positioned(
                    top: 50,
                    right: -20,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 20,
                    right: 20,
                    child: Icon(
                      Icons.star,
                      color: Colors.yellow,
                      size: 30,
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    child: Container(
                      width: 50,
                      height: 50,
                      color: Colors.black.withOpacity(0.2),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      Expanded(
        flex: 1,
        child: Align(
          alignment: Alignment.centerRight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
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
    ];
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('DEBUG: Home build');
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
                horizontal: isSmall
                    ? 20
                    : isMedium
                    ? 60
                    : 100,
                vertical: isSmall ? 45 : 80,
              ),
              child: Flex(
                direction: isSmall ? Axis.vertical : Axis.horizontal,
                mainAxisAlignment:
                    isSmall
                        ? MainAxisAlignment.start
                        : MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: isSmall
                    ? _buildSmallChildren()
                    : _buildLargeChildren(),
              ),
            );
          },
        ),
      ),
    );
  }
}
