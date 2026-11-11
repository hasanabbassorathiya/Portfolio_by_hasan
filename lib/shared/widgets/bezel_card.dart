import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_spacing.dart';

/// Double-Bezel ("Doppelrand") nested architecture.
///
/// Outer shell: subtle glass fill + white hairline ring + ambient shadow,
/// concentric radius. Inner core: vannblack fill + top-edge highlight.
///
/// ```dart
/// BezelCard(child: myContent)               // shell + core, padded
/// BezelCard.shell(child: rawContent)        // outer shell only
/// BezelCard.core(child: rawContent)         // inner core only
/// ```
class BezelCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final bool liftOnHover;
  final double shellRadius;
  final double coreRadius;

  const BezelCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.liftOnHover = true,
    this.shellRadius = AppSpacing.radiusShell,
    this.coreRadius = AppSpacing.radiusCore,
  });

  /// Outer shell only — use when the core is custom (images, gradients).
  const BezelCard.shell({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.liftOnHover = true,
  })  : shellRadius = AppSpacing.radiusShell,
        coreRadius = AppSpacing.radiusCore;

  /// Inner core only — place inside a raw shell.
  const BezelCard.core({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.liftOnHover = false,
  })  : shellRadius = 0,
        coreRadius = 0;

  @override
  State<BezelCard> createState() => BezelCardState();
}

class BezelCardState extends State<BezelCard> {
  bool _hovered = false;
  bool _pressed = false;

  BoxDecoration _shellDecoration() {
    return BoxDecoration(
      color: _hovered
          ? AppColors.white08
          : AppColors.glassFill,
      border: Border.all(
        color: _hovered ? AppColors.hairlineStrong : AppColors.hairline,
        width: 1,
      ),
      borderRadius: BorderRadius.circular(widget.shellRadius),
      boxShadow: AppColors.shadowAmbient,
    );
  }

  BoxDecoration _coreDecoration() {
    return BoxDecoration(
      color: widget.onTap != null
          ? (_hovered ? AppColors.surface : AppColors.base)
          : AppColors.base,
      borderRadius: BorderRadius.circular(widget.coreRadius),
      // Machined top-edge highlight (inset equivalent)
      border: const Border(
        top: BorderSide(color: Color(0x21FFFFFF), width: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCoreOnly = widget.shellRadius == 0;

    Widget core = Container(
      padding: widget.padding ?? const EdgeInsets.all(28),
      decoration: isCoreOnly ? null : _coreDecoration(),
      child: widget.child,
    );

    final Widget shell = isCoreOnly
        ? core
        : AnimatedContainer(
            duration: AppMotion.base,
            curve: AppMotion.swiftOut,
            margin: widget.margin,
            padding: const EdgeInsets.all(6),
            decoration: _shellDecoration(),
            transform: _pressed
                ? (Matrix4.identity()..scale(0.985, 0.985))
                : (_hovered && widget.liftOnHover
                    ? (Matrix4.identity()..translate(0.0, -3.0))
                    : Matrix4.identity()),
            transformAlignment: Alignment.center,
            child: core,
          );

    if (isCoreOnly) {
      return shell;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: shell,
      ),
    );
  }
}

/// Static decoration helpers for sections that build raw Containers.
class BezelDecorations {
  BezelDecorations._();

  static BoxDecoration shell({
    bool hovered = false,
    double radius = AppSpacing.radiusShell,
  }) =>
      BoxDecoration(
        color: hovered ? AppColors.white08 : AppColors.glassFill,
        border: Border.all(
          color: hovered ? AppColors.hairlineStrong : AppColors.hairline,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(radius),
        boxShadow: AppColors.shadowAmbient,
      );

  static BoxDecoration core({
    bool hovered = false,
    double radius = AppSpacing.radiusCore,
  }) =>
      BoxDecoration(
        color: hovered ? AppColors.surface : AppColors.base,
        borderRadius: BorderRadius.circular(radius),
        border: const Border(
          top: BorderSide(color: Color(0x21FFFFFF), width: 1),
        ),
      );

  /// Flat content card (no nesting) — hairline ring only.
  static BoxDecoration flat({
    bool hovered = false,
    double radius = AppSpacing.radiusCard,
  }) =>
      BoxDecoration(
        color: hovered ? AppColors.surface : AppColors.base,
        border: Border.all(
          color: hovered ? AppColors.hairlineStrong : AppColors.hairline,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(radius),
        boxShadow: AppColors.shadowAmbient,
      );

  /// Microscopic pill badge / eyebrow tag.
  static BoxDecoration pill({
    bool filled = false,
    Color? fillColor,
  }) =>
      BoxDecoration(
        color: filled ? (fillColor ?? AppColors.accentSubtle) : Colors.transparent,
        border: Border.all(color: AppColors.hairline, width: 1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      );
}
