import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_spacing.dart';

enum BentoSize { small, medium, large, wide, tall }

/// Bento card built on the Double-Bezel architecture with soft
/// pointer-tracked tilt. Positions in the grid come from callers.
class BentoCard extends StatefulWidget {
  final Widget child;
  final BentoSize size;
  final VoidCallback? onTap;
  final Color? accentColor;
  final bool glowOnHover;
  final bool tiltOnHover;
  final EdgeInsetsGeometry? padding;

  const BentoCard({
    super.key,
    required this.child,
    this.size = BentoSize.small,
    this.onTap,
    this.accentColor,
    this.glowOnHover = true,
    this.tiltOnHover = true,
    this.padding,
  });

  @override
  State<BentoCard> createState() => _BentoCardState();
}

class _BentoCardState extends State<BentoCard> {
  bool _hovered = false;
  bool _pressed = false;
  Offset _mousePos = Offset.zero;
  final GlobalKey _cardKey = GlobalKey();

  Matrix4 get _transform {
    if (_pressed) return Matrix4.identity()..scale(0.985, 0.985);
    if (widget.tiltOnHover && _hovered) {
      return Matrix4.identity()
        ..setEntry(3, 2, 0.0012)
        ..rotateY(0.012 * (_mousePos.dx - 0.5) * 2)
        ..rotateX(-0.012 * (_mousePos.dy - 0.5) * 2)
        ..translate(0.0, -2.0);
    }
    return Matrix4.identity();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) {
          setState(() {
            _hovered = false;
            _mousePos = Offset.zero;
          });
        },
        onHover: (event) {
          if (!widget.tiltOnHover) return;
          final box = _cardKey.currentContext?.findRenderObject() as RenderBox?;
          if (box == null) return;
          setState(() {
            _mousePos = Offset(
              event.localPosition.dx / box.size.width,
              event.localPosition.dy / box.size.height,
            );
          });
        },
        child: AnimatedContainer(
          key: _cardKey,
          duration: AppMotion.slow,
          curve: AppMotion.settle,
          transform: _transform,
          transformAlignment: Alignment.center,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: _hovered ? AppColors.white08 : AppColors.glassFill,
            border: Border.all(
              color: _hovered
                  ? (widget.accentColor ?? AppColors.accent)
                      .withValues(alpha: 0.45)
                  : AppColors.hairline,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(AppSpacing.radiusShell),
            boxShadow: widget.glowOnHover && _hovered
                ? [
                    BoxShadow(
                      color: (widget.accentColor ?? AppColors.accent)
                          .withValues(alpha: 0.14),
                      offset: const Offset(0, 20),
                      blurRadius: 70,
                    ),
                  ]
                : AppColors.shadowAmbient,
          ),
          child: Container(
            width: double.infinity,
            padding: widget.padding ?? const EdgeInsets.all(26),
            decoration: BoxDecoration(
              color: _hovered ? AppColors.surface : AppColors.base,
              borderRadius: BorderRadius.circular(AppSpacing.radiusCore),
              border: const Border(
                top: BorderSide(color: Color(0x21FFFFFF), width: 1),
              ),
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
