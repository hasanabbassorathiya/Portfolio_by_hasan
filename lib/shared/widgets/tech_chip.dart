import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_spacing.dart';

class TechChip extends StatefulWidget {
  final String label;
  final String? level;

  const TechChip({
    super.key,
    required this.label,
    this.level,
  });

  @override
  State<TechChip> createState() => _TechChipState();
}

class _TechChipState extends State<TechChip> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.96 : 1.0,
          duration: const Duration(milliseconds: 180),
          curve: AppMotion.settle,
          child: AnimatedContainer(
            duration: AppMotion.fast,
            curve: AppMotion.swiftOut,
            transform: _hovered && !_pressed
                ? (Matrix4.identity()..translate(0.0, -1.0))
                : Matrix4.identity(),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _hovered ? AppColors.glassFill : Colors.transparent,
              border: Border.all(
                color: _hovered ? AppColors.hairlineStrong : AppColors.hairline,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  widget.label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _hovered ? AppColors.textPrimary : AppColors.textSecondary,
                    letterSpacing: 1,
                  ),
                ),
                if (widget.level != null) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.accentSubtle,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                    ),
                    child: Text(
                      widget.level!,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
