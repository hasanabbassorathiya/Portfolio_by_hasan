import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/config/app_config.dart';
import '../../../core/database/portfolio_repository.dart';
import '../../../shared/widgets/text_scramble.dart';
import '../../../shared/widgets/floating_particles.dart';
import '../../../shared/widgets/magnetic_cursor.dart';
import '../../../shared/widgets/decorative_effects.dart';

class HeroSection extends StatefulWidget {
  const HeroSection({super.key});

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection>
    with SingleTickerProviderStateMixin {
  bool _entered = false;
  late final Map<String, dynamic> _profile;

  @override
  void initState() {
    super.initState();
    _profile = PortfolioRepository().profile;
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _entered = true);
    });
  }

  String get _name => (_profile['name'] as String?) ?? '';
  String get _title => (_profile['title'] as String?) ?? '';
  String get _subtitle => (_profile['subtitle'] as String?) ?? '';
  String get _bio => (_profile['bio'] as String?) ?? '';
  String get _avatarUrl => (_profile['avatar_url'] as String?) ?? '';
  String get _resumeUrl => (_profile['resume_url'] as String?) ?? AppConfig.resumeUrl;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final h = MediaQuery.sizeOf(context).height;
    final isMobile = w < 600;
    final isTablet = w < 1200;
    final compact = h < 780;

    return SizedBox(
      height: h,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: AppColors.deep,
            ),
          ),
          Positioned.fill(
            child: FloatingParticles(
              count: isMobile ? 15 : 30,
              color: AppColors.accent,
              maxSize: 2,
              speed: 0.2,
            ),
          ),
          Positioned(
            top: -h * 0.2,
            right: -w * 0.15,
            child: MorphingBlob(
              size: isMobile ? 200 : 400,
              color: AppColors.accent,
              points: 6,
            ),
          ),
          Positioned.fill(
            child: Container(
              margin: EdgeInsets.symmetric(
                horizontal: isMobile ? 20 : (isTablet ? 48 : 80),
                vertical: isMobile ? 48 : (compact ? 64 : 100),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: isMobile ? 1 : 3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimatedSlide(
                          offset: _entered ? Offset.zero : const Offset(0, 0.3),
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeOutCubic,
                          child: AnimatedOpacity(
                            opacity: _entered ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 600),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.accent,
                                border: Border.all(color: AppColors.accent, width: 2),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.deep,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    _subtitle.toUpperCase(),
                                    style: AppTypography.label(AppColors.deep).copyWith(letterSpacing: 4),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: compact ? 16 : 32),
                        if (!isMobile && w > 900)
                          _buildDesktopHero(w, h, compact)
                        else
                          _buildMobileHero(w, h, compact),
                        SizedBox(height: compact ? 24 : 48),
                        _DelayedSlide(
                          delay: 800,
                          entered: _entered,
                          offset: const Offset(0, 0.5),
                          duration: const Duration(milliseconds: 1000),
                          child: AnimatedOpacity(
                            opacity: _entered ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 800),
                            child: _buildCTAButtons(isMobile),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isMobile && w > 900) ...[
                    const SizedBox(width: 48),
                    Expanded(
                      flex: 2,
                      child: _buildProfileImage(h),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Positioned(
            right: isMobile ? 20 : 60,
            top: h * 0.3,
            child: AnimatedOpacity(
              opacity: _entered ? 0.6 : 0.0,
              duration: const Duration(milliseconds: 1000),
              child: Column(
                children: [
                  _buildSideText('FLUTTER'),
                  const SizedBox(height: 12),
                  _buildSideText('ARCHITECT'),
                  const SizedBox(height: 12),
                  _buildSideText('DUBAI'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage(double h) {
    final hasNetworkAvatar = _avatarUrl.isNotEmpty && _avatarUrl.startsWith('http');

    return Center(
      child: AnimatedSlide(
        offset: _entered ? Offset.zero : const Offset(0.3, 0),
        duration: const Duration(milliseconds: 1200),
        curve: Curves.easeOutCubic,
        child: AnimatedOpacity(
          opacity: _entered ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 1000),
          child: Container(
            width: h * 0.4,
            height: h * 0.4,
            constraints: const BoxConstraints(maxWidth: 380, maxHeight: 380),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.accent,
                width: 3,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x4038BDF8),
                  offset: Offset(8, 8),
                ),
              ],
            ),
            child: hasNetworkAvatar
                ? Image.network(
                    _avatarUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildLocalAvatar(),
                  )
                : _buildLocalAvatar(),
          ),
        ),
      ),
    );
  }

  Widget _buildLocalAvatar() {
    return Image.asset(
      'assets/images/profile.png',
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _buildFallbackAvatar(),
    );
  }

  Widget _buildFallbackAvatar() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
      ),
      child: Center(
        child: Text(
          _name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').join(),
          style: TextStyle(
            fontSize: 80,
            fontWeight: FontWeight.w900,
            color: AppColors.accent.withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopHero(double w, double h, bool compact) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DelayedSlide(
          delay: 200,
          entered: _entered,
          offset: const Offset(0, 0.4),
          duration: const Duration(milliseconds: 1000),
          child: AnimatedOpacity(
            opacity: _entered ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 800),
            child: TextScramble(
              text: _name.toUpperCase(),
              style: TextStyle(
                fontSize: (w * 0.07).clamp(48, 96),
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
                height: 0.95,
                letterSpacing: -2,
              ),
              delay: const Duration(milliseconds: 600),
              duration: const Duration(milliseconds: 2000),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _DelayedSlide(
          delay: 400,
          entered: _entered,
          offset: const Offset(0, 0.4),
          duration: const Duration(milliseconds: 1000),
          child: AnimatedOpacity(
            opacity: _entered ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 800),
            child: TextScramble(
              text: _title.toUpperCase(),
              style: TextStyle(
                fontSize: (w * 0.025).clamp(18, 28),
                fontWeight: FontWeight.w700,
                color: AppColors.accent,
                height: 1.3,
                letterSpacing: 6,
              ),
              delay: const Duration(milliseconds: 1200),
              duration: const Duration(milliseconds: 1500),
            ),
          ),
        ),
        const SizedBox(height: 32),
        _DelayedSlide(
          delay: 600,
          entered: _entered,
          offset: const Offset(0, 0.3),
          duration: const Duration(milliseconds: 800),
          child: AnimatedOpacity(
            opacity: _entered ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 600),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Text(
                _bio,
                style: AppTypography.body().copyWith(
                  fontSize: 16,
                  height: 1.8,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileHero(double w, double h, bool compact) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!compact)
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.accent, width: 2),
                ),
                child: _avatarUrl.isNotEmpty && _avatarUrl.startsWith('http')
                    ? Image.network(_avatarUrl, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildLocalAvatar(),
                      )
                    : _buildLocalAvatar(),
              ),
            ),
          ),
        TextScramble(
          text: _name.toUpperCase(),
          style: TextStyle(
            fontSize: (w * 0.09).clamp(32, 56),
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
            height: 0.95,
            letterSpacing: -1,
          ),
          delay: const Duration(milliseconds: 400),
          duration: const Duration(milliseconds: 1800),
        ),
        const SizedBox(height: 12),
        TextScramble(
          text: _title.toUpperCase(),
          style: TextStyle(
            fontSize: (w * 0.04).clamp(14, 20),
            fontWeight: FontWeight.w700,
            color: AppColors.accent,
            letterSpacing: 4,
          ),
          delay: const Duration(milliseconds: 1000),
          duration: const Duration(milliseconds: 1200),
        ),
        const SizedBox(height: 24),
        AnimatedOpacity(
          opacity: _entered ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 800),
          child: Text(
            _bio,
            style: AppTypography.body().copyWith(
              fontSize: 14,
              height: 1.8,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCTAButtons(bool isMobile) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        MagneticCursor(
          strength: 0.15,
          child: _CtaButton(
            label: 'View Work',
            icon: Icons.arrow_downward_rounded,
            filled: true,
            onTap: () {
              final ctx = context;
              Scrollable.ensureVisible(
                ctx,
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
              );
            },
          ),
        ),
        MagneticCursor(
          strength: 0.15,
          child: _CtaButton(
            label: 'Download CV',
            icon: Icons.open_in_new_rounded,
            filled: false,
            onTap: () => launchUrl(
              Uri.parse(_resumeUrl),
              mode: LaunchMode.externalApplication,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSideText(String text) {
    return RotatedBox(
      quarterTurns: 1,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.textMuted.withValues(alpha: 0.5),
          letterSpacing: 6,
        ),
      ),
    );
  }
}

class _CtaButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool filled;
  final VoidCallback onTap;

  const _CtaButton({
    required this.label,
    required this.icon,
    required this.filled,
    required this.onTap,
  });

  @override
  State<_CtaButton> createState() => _CtaButtonState();
}

class _CtaButtonState extends State<_CtaButton> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          transform: _pressed
              ? (Matrix4.identity()..translate(2.0, 2.0))
              : Matrix4.identity(),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          decoration: BoxDecoration(
            color: widget.filled
                ? (_hovered ? AppColors.accentHover : AppColors.accent)
                : (_hovered ? AppColors.accent.withValues(alpha: 0.15) : Colors.transparent),
            border: Border.all(
              color: widget.filled
                  ? AppColors.accent
                  : (_hovered ? AppColors.accent : AppColors.border),
              width: 2,
            ),
            boxShadow: [
              if (!_pressed)
                BoxShadow(
                  color: _hovered && widget.filled
                      ? AppColors.accent.withValues(alpha: 0.3)
                      : Colors.black.withValues(alpha: 0.3),
                  offset: const Offset(4, 4),
                ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: 18,
                color: widget.filled ? AppColors.deep : AppColors.accent,
              ),
              const SizedBox(width: 10),
              Text(
                widget.label.toUpperCase(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: widget.filled ? AppColors.deep : AppColors.accent,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DelayedSlide extends StatefulWidget {
  final Widget child;
  final int delay;
  final bool entered;
  final Offset offset;
  final Duration duration;

  const _DelayedSlide({
    required this.child,
    required this.delay,
    required this.entered,
    required this.offset,
    required this.duration,
  });

  @override
  State<_DelayedSlide> createState() => _DelayedSlideState();
}

class _DelayedSlideState extends State<_DelayedSlide> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) setState(() => _ready = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: _ready && widget.entered ? Offset.zero : widget.offset,
      duration: widget.duration,
      curve: Curves.easeOutCubic,
      child: widget.child,
    );
  }
}
