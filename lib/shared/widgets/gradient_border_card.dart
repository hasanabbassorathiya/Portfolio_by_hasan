import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class GradientBorderCard extends StatefulWidget {
  final Widget child;
  final double borderRadius;
  final double borderWidth;
  final Duration rotateDuration;
  final VoidCallback? onTap;

  const GradientBorderCard({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.borderWidth = 1.5,
    this.rotateDuration = const Duration(seconds: 4),
    this.onTap,
  });

  @override
  State<GradientBorderCard> createState() => _GradientBorderCardState();
}

class _GradientBorderCardState extends State<GradientBorderCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.rotateDuration)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Container(
              padding: EdgeInsets.all(widget.borderWidth),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                gradient: _hovered
                    ? SweepGradient(
                        center: Alignment.center,
                        startAngle: _controller.value * 2 * 3.14159,
                        endAngle: (_controller.value + 0.5) * 2 * 3.14159,
                        colors: const [
                          AppColors.accent,
                          AppColors.accentHover,
                          Colors.tealAccent,
                          AppColors.accent,
                        ],
                      )
                    : null,
                border: _hovered
                    ? null
                    : Border.all(
                        color: AppColors.surface,
                        width: widget.borderWidth,
                      ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.base,
                  borderRadius: BorderRadius.circular(widget.borderRadius - widget.borderWidth),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(widget.borderRadius - widget.borderWidth),
                  child: widget.child,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class HexGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;

  const HexGrid({
    super.key,
    required this.children,
    this.spacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      children: children,
    );
  }
}

class TechChip extends StatefulWidget {
  final String label;
  final String? level;
  final bool selected;

  const TechChip({
    super.key,
    required this.label,
    this.level,
    this.selected = false,
  });

  @override
  State<TechChip> createState() => _TechChipState();
}

class _TechChipState extends State<TechChip> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: _hovered
              ? AppColors.accent.withValues(alpha: 0.1)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _hovered
                ? AppColors.accent.withValues(alpha: 0.4)
                : AppColors.surface,
          ),
          boxShadow: _hovered
              ? [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    blurRadius: 12,
                    spreadRadius: -2,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _hovered ? AppColors.accent : AppColors.textMuted,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: _hovered ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
            if (widget.level != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  widget.level!,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accent,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
