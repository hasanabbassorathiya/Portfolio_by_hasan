import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
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
  int _currentSection = 0;
  bool _navVisible = true;
  double _lastOffset = 0;

  final _sectionKeys = List.generate(10, (i) => GlobalKey());

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
            setState(() => _currentSection = i);
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
          curve: Curves.easeOutCubic,
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
    final w = MediaQuery.sizeOf(context).width;
    final isMobile = w < 1024;

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
              if (!isMobile)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: AnimatedSlide(
                    offset: _navVisible ? Offset.zero : const Offset(0, -2),
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    child: AnimatedOpacity(
                      opacity: _navVisible ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: FloatingNav(
                        currentSection: _currentSection,
                        items: [
                          NavItem(label: 'Home', onTap: () => _scrollToSection(0)),
                          NavItem(label: 'About', onTap: () => _scrollToSection(1)),
                          NavItem(label: 'Services', onTap: () => _scrollToSection(2)),
                          NavItem(label: 'Work', onTap: () => _scrollToSection(3)),
                          NavItem(label: 'Experience', onTap: () => _scrollToSection(4)),
                          NavItem(label: 'Blog', onTap: () => _scrollToSection(6)),
                          NavItem(label: 'Contact', onTap: () => _scrollToSection(7)),
                        ],
                      ),
                    ),
                  ),
                ),
              if (isMobile) _buildBottomNav(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.base.withValues(alpha: 0.95),
          border: Border(top: BorderSide(color: AppColors.surface)),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _bottomNavItem(0, Icons.home_rounded, 'Home'),
              _bottomNavItem(1, Icons.person_outline_rounded, 'About'),
              _bottomNavItem(2, Icons.work_outline_rounded, 'Work'),
              _bottomNavItem(3, Icons.mail_outline_rounded, 'Contact'),
              _bottomNavItem(4, Icons.more_horiz_rounded, 'More'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bottomNavItem(int index, IconData icon, String label) {
    final isActive = _currentSection == index;
    return GestureDetector(
      onTap: () => _scrollToSection(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isActive ? 20 : 0,
              height: 3,
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 6),
            Icon(
              icon,
              size: 22,
              color: isActive ? AppColors.accent : AppColors.textMuted,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isActive ? AppColors.accent : AppColors.textMuted,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
