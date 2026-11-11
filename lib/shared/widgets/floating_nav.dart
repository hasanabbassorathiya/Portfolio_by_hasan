import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_spacing.dart';

class NavItem {
  final String label;
  final VoidCallback onTap;

  const NavItem({required this.label, required this.onTap});
}

/// Floating glass pill navigation.
///
/// Desktop: logo + section links + CTA, detached from the top edge.
/// Mobile: logo + hamburger; opens a full-screen glass overlay whose
/// links reveal with a staggered fade-up. The hamburger fluidly
/// morphs into an X.
class FloatingNav extends StatefulWidget {
  final int currentSection;
  final List<NavItem> items;
  final VoidCallback? onCtaPressed;

  const FloatingNav({
    super.key,
    required this.currentSection,
    required this.items,
    this.onCtaPressed,
  });

  @override
  State<FloatingNav> createState() => FloatingNavState();
}

class FloatingNavState extends State<FloatingNav>
    with SingleTickerProviderStateMixin {
  late final AnimationController _menuCtrl;
  bool _showOverlay = false;

  @override
  void initState() {
    super.initState();
    _menuCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _menuCtrl.addStatusListener((status) {
      if (status == AnimationStatus.dismissed && mounted) {
        setState(() => _showOverlay = false);
      }
    });
  }

  @override
  void dispose() {
    _menuCtrl.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _showOverlay = !_showOverlay;
      if (_showOverlay) {
        _menuCtrl.forward();
      } else {
        _menuCtrl.reverse();
      }
    });
  }

  void _pickItem(NavItem item) {
    _toggleMenu();
    // Let the overlay start closing before scrolling.
    Future.delayed(const Duration(milliseconds: 200), item.onTap);
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final isMobile = w < 1024;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin: EdgeInsets.only(
            top: 16,
            left: isMobile ? 16 : 24,
            right: isMobile ? 16 : 24,
          ),
          decoration: const BoxDecoration(shape: BoxShape.circle),
          clipBehavior: Clip.none,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                width: isMobile ? double.infinity : null,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.glassScrim,
                  border: Border.all(color: AppColors.hairline, width: 1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                  boxShadow: AppColors.shadowAmbient,
                ),
                child: isMobile ? _buildMobileRow() : _buildDesktopRow(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _logo() {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.center,
      child: const Text(
        'HA',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w800,
          fontSize: 15,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildDesktopRow() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _logo(),
        const SizedBox(width: 4),
        ...List.generate(widget.items.length, (i) {
          final item = widget.items[i];
          final isActive = widget.currentSection == i;
          return GestureDetector(
            onTap: item.onTap,
            child: AnimatedContainer(
              duration: AppMotion.fast,
              curve: AppMotion.swiftOut,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 1),
              decoration: BoxDecoration(
                color: isActive ? AppColors.glassFill : Colors.transparent,
                border: Border.all(
                  color: isActive ? AppColors.hairlineStrong : Colors.transparent,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
              ),
              child: Text(
                item.label.toUpperCase(),
                style: TextStyle(
                  color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 12,
                  letterSpacing: 1.4,
                ),
              ),
            ),
          );
        }),
        if (widget.onCtaPressed != null) ...[
          const SizedBox(width: 4),
          _CtaIsland(onPressed: widget.onCtaPressed!),
        ],
      ],
    );
  }

  Widget _buildMobileRow() {
    return Row(
      children: [
        _logo(),
        const Spacer(),
        if (widget.onCtaPressed != null) ...[
          _CtaIsland(onPressed: widget.onCtaPressed!, compact: true),
          const SizedBox(width: 2),
        ],
        _Hamburger(
          controller: _menuCtrl,
          isOpen: _showOverlay,
          onTap: _toggleMenu,
        ),
      ],
    );
  }

  /// Full-screen glass menu. Built via a Stack overlay injected at the
  /// top of the widget tree through Navigator-independent composition:
  /// the parent screen places this below the nav using [FloatingNavOverlay].
  Widget buildOverlay() {
    if (!_showOverlay) return const SizedBox.shrink();
    return FloatingNavOverlay(
      controller: _menuCtrl,
      items: widget.items,
      currentSection: widget.currentSection,
      onPick: _pickItem,
      onCtaPressed: widget.onCtaPressed == null
          ? null
          : () {
              _toggleMenu();
              Future.delayed(const Duration(milliseconds: 200),
                  widget.onCtaPressed!);
            },
    );
  }
}

class _CtaIsland extends StatefulWidget {
  final VoidCallback onPressed;
  final bool compact;

  const _CtaIsland({required this.onPressed, this.compact = false});

  @override
  State<_CtaIsland> createState() => _CtaIslandState();
}

class _CtaIslandState extends State<_CtaIsland> {
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
          widget.onPressed();
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.96 : 1.0,
          duration: const Duration(milliseconds: 180),
          curve: AppMotion.settle,
          child: AnimatedContainer(
            duration: AppMotion.fast,
            curve: AppMotion.swiftOut,
            padding: widget.compact
                ? const EdgeInsets.symmetric(horizontal: 14, vertical: 12)
                : const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
            decoration: BoxDecoration(
              color: _hovered ? AppColors.accentHover : AppColors.accent,
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent
                      .withValues(alpha: _hovered ? 0.4 : 0.2),
                  offset: const Offset(0, 8),
                  blurRadius: 28,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!widget.compact)
                  Text(
                    "LET'S TALK",
                    style: TextStyle(
                      color: AppColors.deep,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      letterSpacing: 1.4,
                    ),
                  ),
                if (!widget.compact) const SizedBox(width: 8),
                AnimatedContainer(
                  duration: AppMotion.fast,
                  curve: AppMotion.swiftOut,
                  width: 22,
                  height: 22,
                  transform: _hovered
                      ? (Matrix4.identity()
                        ..translate(3.0, -1.0)
                        ..scale(1.08, 1.08))
                      : Matrix4.identity(),
                  transformAlignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.deep.withValues(alpha: 0.12),
                  ),
                  child: PhosphorIcon(
                    PhosphorIconsLight.arrowUpRight,
                    size: 13,
                    color: AppColors.deep,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Bars that fluidly morph between hamburger and X, driven by the
/// menu controller's value (no implicit-animation fighting).
class _Hamburger extends StatelessWidget {
  final AnimationController controller;
  final bool isOpen;
  final VoidCallback onTap;

  const _Hamburger({
    required this.controller,
    required this.isOpen,
    required this.onTap,
  });

  static const _tweenCurve = AppMotion.swiftOut;

  double _barAngle(double t, bool reverse) =>
      (reverse ? -1 : 1) * (t * 0.125); // 45deg

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isOpen ? AppColors.glassFill : Colors.transparent,
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: controller,
            builder: (context, _) {
              final t = _tweenCurve.transform(controller.value);
              final spread = 5.0 * (1 - t); // bars converge to center
              final barW = 18.0;
              final bar = (double w) => Container(
                    width: w,
                    height: 2,
                    decoration: BoxDecoration(
                      color: AppColors.textPrimary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
              return SizedBox(
                width: barW,
                height: 16,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Transform.translate(
                      offset: Offset(0, -spread),
                      child: Transform.rotate(
                        angle: -t * 0.7853981634, // -45deg
                        child: bar(barW),
                      ),
                    ),
                    Opacity(
                      opacity: (1 - t).clamp(0.0, 1.0),
                      child: bar(barW),
                    ),
                    Transform.translate(
                      offset: Offset(0, spread),
                      child: Transform.rotate(
                        angle: t * 0.7853981634, // +45deg
                        child: bar(barW),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Full-screen glass overlay with staggered link reveal.
class FloatingNavOverlay extends StatelessWidget {
  final AnimationController controller;
  final List<NavItem> items;
  final int currentSection;
  final void Function(NavItem) onPick;
  final VoidCallback? onCtaPressed;

  const FloatingNavOverlay({
    super.key,
    required this.controller,
    required this.items,
    required this.currentSection,
    required this.onPick,
    this.onCtaPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final t = controller.value;
        return Positioned.fill(
          child: IgnorePointer(
            ignoring: t < 0.05,
            child: Opacity(
              opacity: CurvedAnimation(parent: controller, curve: Curves.easeOut)
                  .value,
              child: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 28 * t,
                    sigmaY: 28 * t,
                  ),
                  child: Container(
                    color: AppColors.glassScrim,
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 100),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ...List.generate(items.length, (i) {
                              final progress = CurvedAnimation(
                                parent: controller,
                                curve: Interval(
                                  0.1 + i * 0.05,
                                  0.5 + i * 0.05,
                                  curve: AppMotion.reveal,
                                ),
                              ).value;
                              return Transform.translate(
                                offset: Offset(0, 32 * (1 - progress)),
                                child: Opacity(
                                  opacity: progress,
                                  child: _OverlayLink(
                                    item: items[i],
                                    index: i,
                                    isActive: currentSection == i,
                                    onTap: () => onPick(items[i]),
                                  ),
                                ),
                              );
                            }),
                            const Spacer(),
                            if (onCtaPressed != null)
                              Opacity(
                                opacity: CurvedAnimation(
                                  parent: controller,
                                  curve: const Interval(
                                      0.55, 0.9, curve: AppMotion.reveal),
                                ).value,
                                child: _OverlayCta(onPressed: onCtaPressed!),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _OverlayLink extends StatefulWidget {
  final NavItem item;
  final int index;
  final bool isActive;
  final VoidCallback onTap;

  const _OverlayLink({
    required this.item,
    required this.index,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_OverlayLink> createState() => _OverlayLinkState();
}

class _OverlayLinkState extends State<_OverlayLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              AnimatedDefaultTextStyle(
                duration: AppMotion.fast,
                curve: AppMotion.swiftOut,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: widget.isActive
                      ? AppColors.accent
                      : (_hovered
                          ? AppColors.textPrimary
                          : AppColors.textSecondary),
                ),
                child: Text(widget.item.label),
              ),
              const SizedBox(width: 14),
              AnimatedOpacity(
                opacity: _hovered || widget.isActive ? 1 : 0,
                duration: AppMotion.fast,
                curve: AppMotion.swiftOut,
                child: Transform.translate(
                  offset: Offset(_hovered ? 0 : -6, 0),
                  child: Text(
                    '0${widget.index + 1}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OverlayCta extends StatelessWidget {
  final VoidCallback onPressed;

  const _OverlayCta({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withValues(alpha: 0.3),
                offset: const Offset(0, 12),
                blurRadius: 40,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "LET'S TALK",
                style: TextStyle(
                  color: AppColors.deep,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.deep.withValues(alpha: 0.12),
                ),
                child: PhosphorIcon(
                  PhosphorIconsLight.arrowUpRight,
                  size: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
