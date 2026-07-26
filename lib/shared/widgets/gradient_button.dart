import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

enum GradientButtonSize { small, medium, large }

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
    switch (widget.size) {
      case GradientButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 10);
      case GradientButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 28, vertical: 14);
      case GradientButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 36, vertical: 18);
    }
  }

  double get _fontSize {
    switch (widget.size) {
      case GradientButtonSize.small:
        return 13;
      case GradientButtonSize.medium:
        return 15;
      case GradientButtonSize.large:
        return 17;
    }
  }

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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
          transform: _pressed
              ? (Matrix4.identity()..translate(2.0, 2.0))
              : Matrix4.identity(),
          padding: _padding,
          decoration: BoxDecoration(
            color: widget.outlined
                ? (_hovered ? AppColors.accent.withValues(alpha: 0.15) : Colors.transparent)
                : (_hovered ? AppColors.accentHover : AppColors.accent),
            border: Border.all(
              color: widget.outlined
                  ? (_hovered ? AppColors.accent : AppColors.border)
                  : AppColors.accent,
              width: 2,
            ),
            boxShadow: [
              if (!_pressed)
                BoxShadow(
                  color: _hovered && !widget.outlined
                      ? AppColors.accent.withValues(alpha: 0.3)
                      : Colors.black.withValues(alpha: 0.3),
                  offset: const Offset(4, 4),
                ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 18, color: widget.outlined ? AppColors.accent : AppColors.deep),
                const SizedBox(width: 8),
              ],
              Text(
                widget.label.toUpperCase(),
                style: TextStyle(
                  fontSize: _fontSize,
                  fontWeight: FontWeight.w700,
                  color: widget.outlined ? AppColors.accent : AppColors.deep,
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
