import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:portfolio/core/repositories/social_link_repository.dart';
import 'package:portfolio/core/repositories/profile_repository.dart';
import 'package:portfolio/models/social_link/social_link_model.dart';
import 'package:portfolio/shared/constants/colors.dart';
import 'package:portfolio/shared/constants/textstyles.dart';
import 'package:portfolio/shared/constants/utils.dart';
import 'package:portfolio/shared/widgets/button.dart';
import 'package:portfolio/shared/widgets/profile_image_widget.dart';
import 'package:portfolio/shared/widgets/gradient_text.dart';
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
  final SocialLinkRepository _socialLinkRepository = SocialLinkRepository();
  final ProfileRepository _profileRepository = ProfileRepository();
  List<SocialLinkModel> _socialLinks = [];
  String? _quote;
  String? _phone;
  String? _email;
  String? _location;
  String? _name;
  String? _title;
  String? _bio;
  int? _yearsOfExperience;
  bool _isLoadingSocialLinks = true;

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
    _loadSocialLinks();
    _loadProfile();
  }

  void _trackPageView() {
    AnalyticsService.trackPageView(pagePath: '/about', pageTitle: 'About');
  }


  Future<void> _loadSocialLinks() async {
    try {
      final socialLinks = await _socialLinkRepository.getAllSocialLinks();
      setState(() {
        _socialLinks = socialLinks;
        _isLoadingSocialLinks = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingSocialLinks = false;
      });
    }
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _profileRepository.getProfile();
      if (profile != null) {
        setState(() {
          _quote = profile.quote;
          _phone = profile.phone;
          _email = profile.email;
          _location = profile.location;
          _name = profile.name;
          _title = profile.title;
          _bio = profile.bio;
          _yearsOfExperience = profile.yearsOfExperience;
        });
      }
    } catch (e) {
      // Silently fail, will use fallback values
    }
  }

  IconData _getIconForPlatform(String platform) {
    switch (platform.toLowerCase()) {
      case 'linkedin':
        return FontAwesomeIcons.linkedin;
      case 'github':
        return FontAwesomeIcons.githubAlt; // Using githubAlt for better visibility
      case 'twitter':
        return FontAwesomeIcons.twitter;
      case 'facebook':
        return FontAwesomeIcons.facebook;
      case 'instagram':
        return Iconsax.instagram_copy;
      case 'behance':
        return FontAwesomeIcons.behance;
      case 'dribbble':
        return FontAwesomeIcons.dribbble;
      default:
        return Icons.link;
    }
  }

  String _getPlatformFromUrl(String url) {
    final lowerUrl = url.toLowerCase();
    if (lowerUrl.contains('linkedin.com')) return 'linkedin';
    if (lowerUrl.contains('github.com')) return 'github';
    if (lowerUrl.contains('twitter.com') || lowerUrl.contains('x.com')) {
      return 'twitter';
    }
    if (lowerUrl.contains('facebook.com')) return 'facebook';
    if (lowerUrl.contains('instagram.com')) return 'instagram';
    if (lowerUrl.contains('behance.net')) return 'behance';
    if (lowerUrl.contains('dribbble.com')) return 'dribbble';
    return 'unknown';
  }

  void _activatePage() {
    _animationController.forward(from: 0.0);
  }

  // Key for ProfileImageWidget to force refresh
  GlobalKey _profileImageKey = GlobalKey();

  @override
  void didUpdateWidget(covariant About oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _activatePage();
      // Refresh profile image when page becomes active
      _refreshProfileImage();
    } else if (!widget.isActive && oldWidget.isActive) {
      _animationController.reset();
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
            _buildYearsOfExperienceSection(context, isSmall, isMedium),
            AppUtils().vSpace(size: isSmall ? 40.0 : 80.0),
            _buildQuoteSection(context, isSmall, isMedium),
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
                      _name ?? 'Welcome to...',
                      style: AppStyles.heading(
                        color: AppColors.primaryColor,
                        fontSize: isSmall ? 36 : 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    AppUtils().vSpace(size: isSmall ? 24.0 : 40.0),
                    Container(
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
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: ProfileImageWidget(
                          key: _profileImageKey,
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
                      ),
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
                      (_name ?? 'HASAN ABBAS SORATHIYA').toUpperCase(),
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
                    if (_title != null && _title!.isNotEmpty) ...[
                      AppUtils().vSpace(size: isSmall ? 12.0 : 16.0),
                      Text(
                        _title!.toUpperCase(),
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
                    if (_bio != null && _bio!.isNotEmpty) ...[
                      AppUtils().vSpace(size: isSmall ? 24.0 : 32.0),
                      Text(
                        _bio!,
                        style: AppStyles.body(
                          fontSize: isSmall ? 16.0 : 20.0,
                        ),
                      ),
                    ],
                    AppUtils().vSpace(size: isSmall ? 32.0 : 48.0),
                    AppButton(
                      title: 'Download CV 	',
                      icons: Iconsax.arrow_right_3_copy,
                      onTap: () {
                        AnalyticsService.trackDownload(
                          fileType: 'pdf',
                          fileName: 'CV',
                        );
                        LinkUtils.launchUrl(
                          AppLinks.cvLink,
                          linkType: 'cv_download',
                          linkName: 'CV',
                        );
                      },
                    ),
                    AppUtils().vSpace(size: isSmall ? 30.0 : 40.0),
                    _buildContactInfo(context, isSmall, isMedium),
                    AppUtils().vSpace(size: isSmall ? 24.0 : 32.0),
                    _buildSocialLinks(context, isSmall),
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
                child: Container(
                  width: isSmall ? 180.0 : 260.0,
                  height: isSmall ? 180.0 : 260.0,
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
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: ProfileImageWidget(
                      key: _profileImageKey,
                      width: isSmall ? 180.0 : 260.0,
                      height: isSmall ? 180.0 : 260.0,
                      fit: BoxFit.cover,
                    ),
                  ),
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
                      text: (_title ?? 'Software Engineer').toUpperCase(),
                      style: AppStyles.heading(
                        fontSize: isSmall ? 16.0 : 24.0,
                        fontWeight: FontWeight.bold,
                      ).copyWith(fontStyle: FontStyle.italic),
                    ),
                    if (_location != null && _location!.isNotEmpty) ...[
                      TextSpan(
                        text: ' based in '.toUpperCase(),
                        style: AppStyles.heading(fontSize: isSmall ? 16.0 : 24.0),
                      ),
                      TextSpan(
                        text: _location!.toUpperCase(),
                        style: AppStyles.heading(
                          fontSize: isSmall ? 16.0 : 24.0,
                          fontWeight: FontWeight.bold,
                        ).copyWith(fontStyle: FontStyle.italic),
                      ),
                    ],
                  ],
                ),
              ),
              AppUtils().vSpace(size: isSmall ? 24.0 : 32.0),
              AppButton(
                title: 'Download CV 	',
                icons: Iconsax.arrow_right_3_copy,
                onTap: () {
                  AnalyticsService.trackDownload(
                    fileType: 'pdf',
                    fileName: 'CV',
                  );
                  LinkUtils.launchUrl(
                    AppLinks.cvLink,
                    linkType: 'cv_download',
                    linkName: 'CV',
                  );
                },
              ),
              AppUtils().vSpace(size: isSmall ? 30.0 : 40.0),
              _buildContactInfo(context, isSmall, isMedium),
              AppUtils().vSpace(size: isSmall ? 24.0 : 32.0),
              _buildSocialLinks(context, isSmall),
            ],
          );
        }
      },
    );
  }

  Widget _buildSocialLinks(BuildContext context, bool isSmall) {
    if (_isLoadingSocialLinks) {
      return const SizedBox.shrink();
    }

    if (_socialLinks.isEmpty) {
      // Fallback to hardcoded links if database is empty
      return Wrap(
        spacing: 16.0,
        runSpacing: 16.0,
        children: [
          _buildSocialIcon(
            context,
            FontAwesomeIcons.linkedin,
            AppLinks.linkedIn,
            isSmall,
          ),
          _buildSocialIcon(
            context,
            Iconsax.instagram_copy,
            AppLinks.instagram,
            isSmall,
          ),
          _buildSocialIcon(
            context,
            Iconsax.facebook_copy,
            AppLinks.facebook,
            isSmall,
          ),
          if (AppLinks.github.isNotEmpty &&
              AppLinks.github != 'YOUR_GITHUB_PROFILE')
            _buildSocialIcon(
              context,
              FontAwesomeIcons.github,
              AppLinks.github,
              isSmall,
            ),
        ],
      );
    }

    return Wrap(
      spacing: 16.0,
      runSpacing: 16.0,
      children:
          _socialLinks.map((link) {
            return _buildSocialIcon(
              context,
              _getIconForPlatform(link.platform),
              link.url,
              isSmall,
            );
          }).toList(),
    );
  }

  Widget _buildSocialIcon(
    BuildContext context,
    IconData icon,
    String url,
    bool isSmall,
  ) {
    return InkWell(
      onTap: () {
        // Extract platform from URL
        final platform = _getPlatformFromUrl(url);
        AnalyticsService.trackEvent(
          eventName: 'social_link_clicked',
          eventData: {'platform': platform, 'url': url},
        );
        LinkUtils.launchUrl(
          url,
          linkType: 'social_$platform',
          linkName: platform,
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: isSmall ? 44.0 : 50.0,
        height: isSmall ? 44.0 : 50.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.bgColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: isSmall ? 20 : 24,
          color: AppColors.primaryColor,
        ),
      ),
    );
  }

  Widget _buildContactInfo(BuildContext context, bool isSmall, bool isMedium) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_phone != null && _phone!.isNotEmpty) ...[
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
                onTap: () => LinkUtils.launchPhone(_phone!),
                child: Text(
                  _phone!,
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
        ],
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
              onTap: () => LinkUtils.launchEmail(_email ?? AppLinks.email),
              child: Text(
                _email ?? AppLinks.email,
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
              _location ?? 'Dubai, UAE', // Location from profile or fallback
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


  // Years of Experience Section matching Figma design
  Widget _buildYearsOfExperienceSection(BuildContext context, bool isSmall, bool isMedium) {
    if (_yearsOfExperience == null) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isVerticalLayout = isSmall || isMedium;
        
        return Flex(
          direction: isVerticalLayout ? Axis.vertical : Axis.horizontal,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Years of Experience Section
            Flexible(
              flex: 1,
              fit: FlexFit.loose,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GradientText(
                        '$_yearsOfExperience+',
                        gradient: AppUtils().appGradient,
                        style: AppStyles.heading(
                          fontSize: isSmall ? 40.0 : 60.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      Flexible(
                        child: Text(
                          'Years\nexperience...',
                          style: AppStyles.subheading(
                            fontWeight: FontWeight.bold,
                            fontSize: isSmall ? 20.0 : 28.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  AppUtils().vSpace(size: isSmall ? 12.0 : 16.0),
                  if (_bio != null && _bio!.isNotEmpty)
                    Text(
                      _bio!,
                      softWrap: true,
                      style: AppStyles.body(fontSize: isSmall ? 16.0 : 20.0),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // Extracted method for Quote Section (reused)
  Widget _buildQuoteSection(BuildContext context, bool isSmall, bool isMedium) {
    if (_quote == null || _quote!.isEmpty) {
      return const SizedBox.shrink();
    }
    
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
                _quote!,
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

}
