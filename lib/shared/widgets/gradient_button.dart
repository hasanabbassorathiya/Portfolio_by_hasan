import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_spacing.dart';

enum GradientButtonSize { small, medium, large }

/// Nesting CTA "island" button — fully rounded pill whose trailing icon
/// lives inside its own circular wrapper (button-in-button).
///
/// Hover: inner icon circle translates diagonally + scales.
/// Press: whole button scales to 0.98 (physical press).
class GradientButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final bool outlined;
  final GradientButtonSize size;
  final IconData? icon;

  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.outlined = false,
    this.size = GradientButtonSize.medium,
    this.icon,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> {
  bool _hovered = false;
  bool _pressed = false;

  EdgeInsets get _padding {
    // Left padding generous, right flush against the nested icon circle.
    switch (widget.size) {
      case GradientButtonSize.small:
        return const EdgeInsets.only(left: 20, right: 8, top: 8, bottom: 8);
      case GradientButtonSize.medium:
        return const EdgeInsets.only(left: 28, right: 10, top: 10, bottom: 10);
      case GradientButtonSize.large:
        return const EdgeInsets.only(left: 32, right: 12, top: 12, bottom: 12);
    }
  }

  double get _fontSize {
    switch (widget.size) {
      case GradientButtonSize.small:
        return 13;
      case GradientButtonSize.medium:
        return 14;
      case GradientButtonSize.large:
        return 15;
    }
  }

  double get _iconSize {
    switch (widget.size) {
      case GradientButtonSize.small:
        return 28;
      case GradientButtonSize.medium:
        return 32;
      case GradientButtonSize.large:
        return 36;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color fg = widget.outlined ? AppColors.textPrimary : AppColors.deep;
    final Color bg = _hovered
        ? (widget.outlined ? AppColors.white08 : AppColors.accentHover)
        : (widget.outlined ? Colors.transparent : AppColors.accent);

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
          scale: _pressed ? 0.98 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: AppMotion.settle,
          child: AnimatedContainer(
            duration: AppMotion.fast,
            curve: AppMotion.swiftOut,
            padding: _padding,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
              border: Border.all(
                color: widget.outlined
                    ? AppColors.hairlineStrong
                    : Colors.transparent,
                width: 1,
              ),
              boxShadow: [
                if (!widget.outlined)
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: _hovered ? 0.35 : 0.18),
                    offset: const Offset(0, 12),
                    blurRadius: 40,
                  ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.label.toUpperCase(),
                  style: TextStyle(
                    fontSize: _fontSize,
                    fontWeight: FontWeight.w700,
                    color: fg,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(width: widget.size == GradientButtonSize.small ? 8 : 10),
                // The "button-in-button" trailing icon island
                AnimatedContainer(
                  duration: AppMotion.fast,
                  curve: AppMotion.swiftOut,
                  width: _iconSize,
                  height: _iconSize,
                  transform: _hovered
                      ? (Matrix4.identity()
                        ..translate(4.0, -1.0)
                        ..scale(1.06, 1.06))
                      : Matrix4.identity(),
                  transformAlignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.outlined ? AppColors.glassFill : AppColors.deep.withOpacity(0.12),
                  ),
                  child: widget.icon != null
                      ? Icon(widget.icon, size: _iconSize * 0.5, color: fg)
                      : PhosphorIcon(
                          PhosphorIconsLight.arrowUpRight,
                          size: _iconSize * 0.5,
                          color: fg,
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
