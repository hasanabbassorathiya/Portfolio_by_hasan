import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

enum BentoSize { small, medium, large, wide, tall }

class BentoCard extends StatefulWidget {
  final Widget child;
  final BentoSize size;
  final VoidCallback? onTap;
  final Color? accentColor;
  final bool glowOnHover;
  final bool tiltOnHover;

  const BentoCard({
    super.key,
    required this.child,
    this.size = BentoSize.small,
    this.onTap,
    this.accentColor,
    this.glowOnHover = true,
    this.tiltOnHover = true,
  });

  @override
  State<BentoCard> createState() => _BentoCardState();
}

class _BentoCardState extends State<BentoCard> {
  bool _hovered = false;
  bool _pressed = false;
  Offset _mousePos = Offset.zero;
  final GlobalKey _cardKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final accent = widget.accentColor ?? AppColors.accent;

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
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
          transform: _pressed
              ? (Matrix4.identity()..translate(2.0, 2.0))
              : (widget.tiltOnHover && _hovered
                  ? (Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(0.02 * (_mousePos.dx - 0.5) * 2)
                    ..rotateX(-0.02 * (_mousePos.dy - 0.5) * 2))
                  : Matrix4.identity()),
          transformAlignment: Alignment.center,
          decoration: BoxDecoration(
            color: _hovered ? accent : AppColors.base,
            border: Border.all(
              color: _hovered ? accent : AppColors.border,
              width: 2,
            ),
            boxShadow: [
              if (!_pressed && _hovered)
                BoxShadow(
                  color: accent.withValues(alpha: 0.2),
                  offset: const Offset(4, 4),
                ),
              if (!_pressed && !_hovered)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  offset: const Offset(4, 4),
                ),
            ],
          ),
          child: DefaultTextStyle(
            style: TextStyle(
              color: _hovered ? AppColors.deep : AppColors.textPrimary,
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
