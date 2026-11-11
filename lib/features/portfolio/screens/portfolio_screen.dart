import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_motion.dart';
import '../../../shared/widgets/floating_nav.dart';
import '../../../shared/widgets/scroll_progress_bar.dart';
import '../../../shared/widgets/grain_overlay.dart';
import '../../../shared/widgets/marquee_text.dart';
import '../../../shared/widgets/kinetic_divider.dart';
import '../sections/hero_section.dart';
import '../sections/about_section.dart';
import '../sections/services_section.dart';
import '../sections/portfolio_section.dart';
import '../sections/experience_section.dart';
import '../sections/testimonials_section.dart';
import '../sections/blog_section.dart';
import '../sections/contact_section.dart';
import '../sections/newsletter_section.dart';
import '../sections/footer_section.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<FloatingNavState> _navKey = GlobalKey<FloatingNavState>();
  int _currentSection = 0;
  bool _navVisible = true;
  double _lastOffset = 0;

  final _sectionKeys = List.generate(10, (i) => GlobalKey());

  late final List<NavItem> _navItems = [
    NavItem(label: 'Home', onTap: () => _scrollToSection(0)),
    NavItem(label: 'About', onTap: () => _scrollToSection(1)),
    NavItem(label: 'Services', onTap: () => _scrollToSection(2)),
    NavItem(label: 'Work', onTap: () => _scrollToSection(3)),
    NavItem(label: 'Experience', onTap: () => _scrollToSection(4)),
    NavItem(label: 'Blog', onTap: () => _scrollToSection(6)),
    NavItem(label: 'Contact', onTap: () => _scrollToSection(7)),
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final offset = _scrollController.offset;

    for (var i = _sectionKeys.length - 1; i >= 0; i--) {
      final key = _sectionKeys[i];
      if (key.currentContext != null) {
        final box = key.currentContext!.findRenderObject() as RenderBox?;
        if (box != null) {
          final top = box.localToGlobal(Offset.zero).dy + offset;
          if (offset >= top - 200) {
            if (_currentSection != i) setState(() => _currentSection = i);
            break;
          }
        }
      }
    }

    if (offset > _lastOffset && offset > 100) {
      if (_navVisible) setState(() => _navVisible = false);
    } else {
      if (!_navVisible) setState(() => _navVisible = true);
    }
    _lastOffset = offset;
  }

  void _scrollToSection(int index) {
    if (index < _sectionKeys.length) {
      final ctx = _sectionKeys[index].currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 600),
          curve: AppMotion.swiftOut,
        );
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.deep,
        body: GrainOverlay(
          child: Stack(
            children: [
              CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverToBoxAdapter(child: ScrollProgressBar(controller: _scrollController)),
                  SliverToBoxAdapter(child: HeroSection(key: _sectionKeys[0])),
                  SliverToBoxAdapter(child: const KineticDivider(text: 'About')),
                  SliverToBoxAdapter(child: AboutSection(key: _sectionKeys[1])),
                  SliverToBoxAdapter(child: MarqueeText(
                    text: 'FLUTTER · MOBILE · CROSS-PLATFORM · DUBAI · ARCHITECT · OPEN SOURCE ·',
                    backgroundColor: AppColors.accent.withValues(alpha: 0.05),
                  )),
                  SliverToBoxAdapter(child: const KineticDivider(text: 'Services')),
                  SliverToBoxAdapter(child: ServicesSection(key: _sectionKeys[2])),
                  SliverToBoxAdapter(child: const KineticDivider(text: 'Work')),
                  SliverToBoxAdapter(child: PortfolioSection(key: _sectionKeys[3])),
                  SliverToBoxAdapter(child: MarqueeText(
                    text: '50+ PROJECTS · 8+ YEARS · FLUTTER · KOTLIN · SWIFT · FIREBASE ·',
                    textColor: AppColors.accent,
                    backgroundColor: AppColors.deep,
                  )),
                  SliverToBoxAdapter(child: const KineticDivider(text: 'Experience')),
                  SliverToBoxAdapter(child: ExperienceSection(key: _sectionKeys[4])),
                  SliverToBoxAdapter(child: const KineticDivider(text: 'Testimonials')),
                  SliverToBoxAdapter(child: TestimonialsSection(key: _sectionKeys[5])),
                  SliverToBoxAdapter(child: const KineticDivider(text: 'Blog')),
                  SliverToBoxAdapter(child: BlogSection(key: _sectionKeys[6])),
                  SliverToBoxAdapter(child: const KineticDivider(text: 'Contact')),
                  SliverToBoxAdapter(child: ContactSection(key: _sectionKeys[7])),
                  SliverToBoxAdapter(child: NewsletterSection(key: _sectionKeys[8])),
                  SliverToBoxAdapter(child: FooterSection(key: _sectionKeys[9])),
                ],
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: AnimatedSlide(
                  offset: _navVisible ? Offset.zero : const Offset(0, -2),
                  duration: const Duration(milliseconds: 450),
                  curve: AppMotion.swiftOut,
                  child: AnimatedOpacity(
                    opacity: _navVisible ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: FloatingNav(
                      key: _navKey,
                      currentSection: _currentSection,
                      items: _navItems,
                    ),
                  ),
                ),
              ),
              if (_navKey.currentState != null)
                _navKey.currentState!.buildOverlay(),
            ],
          ),
        ),
      ),
    );
  }
}
