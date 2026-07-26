import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class InteractiveOrb extends StatefulWidget {
  final double size;
  final Color color;
  final String? label;

  const InteractiveOrb({
    super.key,
    this.size = 80,
    this.color = AppColors.accent,
    this.label,
  });

  @override
  State<InteractiveOrb> createState() => _InteractiveOrbState();
}

class _InteractiveOrbState extends State<InteractiveOrb>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _hoverController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        _hoverController.forward();
      },
      onExit: (_) {
        _hoverController.reverse();
      },
      child: AnimatedBuilder(
        animation: Listenable.merge([_pulseController, _hoverController]),
        builder: (context, _) {
          final pulse = _pulseController.value;
          final hover = _hoverController.value;

          final currentSize = widget.size * (1 + hover * 0.15);

          return Container(
            width: currentSize,
            height: currentSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: widget.color.withValues(alpha: 0.3 + pulse * 0.1),
                  blurRadius: 20 + pulse * 10 + hover * 20,
                  spreadRadius: -5 + hover * 5,
                ),
                BoxShadow(
                  color: widget.color.withValues(alpha: 0.1),
                  blurRadius: 40 + pulse * 15,
                  spreadRadius: -10,
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    widget.color.withValues(alpha: 0.3 + hover * 0.2),
                    widget.color.withValues(alpha: 0.1),
                    widget.color.withValues(alpha: 0.0),
                  ],
                ),
                border: Border.all(
                  color: widget.color.withValues(alpha: 0.3 + hover * 0.3),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: widget.label != null
                    ? Text(
                        widget.label!,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: widget.color,
                        ),
                      )
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }
}

class StatBlock extends StatelessWidget {
  final String value;
  final String label;
  final bool isCompact;

  const StatBlock({
    super.key,
    required this.value,
    required this.label,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: isCompact ? 32 : 48,
            fontWeight: FontWeight.w800,
            color: AppColors.accent,
            height: 1.0,
            letterSpacing: -2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: isCompact ? 12 : 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textMuted,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
