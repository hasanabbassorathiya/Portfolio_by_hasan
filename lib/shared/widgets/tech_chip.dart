import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          transform: _pressed
              ? (Matrix4.identity()..translate(2.0, 2.0))
              : Matrix4.identity(),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _hovered ? AppColors.accent : AppColors.surface,
            border: Border.all(
              color: _hovered ? AppColors.accent : AppColors.border,
              width: 1,
            ),
            boxShadow: [
              if (!_pressed && _hovered)
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.2),
                  offset: const Offset(2, 2),
                ),
              if (!_pressed && !_hovered)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  offset: const Offset(2, 2),
                ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: _hovered ? AppColors.deep : AppColors.accent,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                widget.label.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _hovered ? AppColors.deep : AppColors.textSecondary,
                  letterSpacing: 1,
                ),
              ),
              if (widget.level != null) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: _hovered ? AppColors.deep.withValues(alpha: 0.2) : AppColors.accent.withValues(alpha: 0.15),
                  ),
                  child: Text(
                    widget.level!,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: _hovered ? AppColors.deep : AppColors.accent,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
