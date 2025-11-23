import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:portfolio/shared/constants/design_tokens.dart';

/// Custom animated cursor widget
/// Creates a modern gradient cursor that follows mouse movement
/// Based on Figma design with smooth animations
class CustomCursor extends StatefulWidget {
  final Widget child;
  final bool enabled;

  const CustomCursor({super.key, required this.child, this.enabled = true});

  @override
  State<CustomCursor> createState() => _CustomCursorState();
}

class _CustomCursorState extends State<CustomCursor>
    with TickerProviderStateMixin {
  Offset _cursorPosition = Offset.zero;
  Offset _animatedPosition = Offset.zero;
  bool _isClicking = false;
  bool _isVisible = false;
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateCursorPosition(PointerEvent event) {
    if (!widget.enabled || !mounted) return;

    setState(() {
      _cursorPosition = event.position;
      _isVisible = true;
    });

    // Smooth animation to cursor position using a timer-based approach
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _animatedPosition =
              Offset.lerp(_animatedPosition, _cursorPosition, 0.2) ??
              _cursorPosition;
        });
      }
    });
  }

  void _onPointerHover(PointerEvent event) {
    if (!widget.enabled) return;
    _updateCursorPosition(event);
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (!widget.enabled) return;
    _updateCursorPosition(event);
  }

  void _onPointerDown(PointerDownEvent event) {
    if (!widget.enabled) return;
    setState(() {
      _isClicking = true;
    });
  }

  void _onPointerUp(PointerUpEvent event) {
    if (!widget.enabled) return;
    setState(() {
      _isClicking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    return Listener(
      onPointerHover: _onPointerHover,
      onPointerMove: _onPointerMove,
      onPointerDown: _onPointerDown,
      onPointerUp: _onPointerUp,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          widget.child,
          // Custom cursor overlay - only show when visible
          if (_isVisible)
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: _CursorPainter(
                        position: _animatedPosition,
                        scale: _isClicking ? 0.7 : 1.0,
                        opacity: _opacityAnimation.value,
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CursorPainter extends CustomPainter {
  final Offset position;
  final double scale;
  final double opacity;

  _CursorPainter({
    required this.position,
    required this.scale,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity == 0 || position.dx < 0 || position.dy < 0) return;

    // Clamp position to canvas bounds
    final clampedPosition = Offset(
      position.dx.clamp(0.0, size.width),
      position.dy.clamp(0.0, size.height),
    );

    final paint =
        Paint()
          ..style = PaintingStyle.fill
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 10);

    // Outer circle with gradient
    final gradient = RadialGradient(
      colors: [
        DesignTokens.gradientOrange.withOpacity(0.3 * opacity),
        DesignTokens.gradientRed.withOpacity(0.2 * opacity),
        DesignTokens.gradientPurple.withOpacity(0.1 * opacity),
      ],
      stops: const [0.0, 0.5, 1.0],
    );

    final radius = 20 * scale;
    final rect = Rect.fromCircle(center: clampedPosition, radius: radius);

    // Ensure rect is within bounds
    final bounds = Rect.fromLTWH(0, 0, size.width, size.height);
    if (!bounds.intersect(rect).isEmpty) {
      paint.shader = gradient.createShader(rect);
      canvas.drawCircle(clampedPosition, radius, paint);

      // Inner dot
      final innerPaint =
          Paint()
            ..color = DesignTokens.primaryDark.withOpacity(0.8 * opacity)
            ..style = PaintingStyle.fill;

      canvas.drawCircle(clampedPosition, 4 * scale, innerPaint);
    }
  }

  @override
  bool shouldRepaint(_CursorPainter oldDelegate) {
    return oldDelegate.position != position ||
        oldDelegate.scale != scale ||
        oldDelegate.opacity != opacity;
  }
}

/// Cursor aware widget that changes cursor on hover
class CursorAware extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onHover;
  final MouseCursor cursor;

  const CursorAware({
    super.key,
    required this.child,
    this.onTap,
    this.onHover,
    this.cursor = SystemMouseCursors.click,
  });

  @override
  State<CursorAware> createState() => _CursorAwareState();
}

class _CursorAwareState extends State<CursorAware> {
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.cursor,
      onEnter: (_) {
        widget.onHover?.call();
      },
      onExit: (_) {
        // Handle exit if needed
      },
      child: GestureDetector(onTap: widget.onTap, child: widget.child),
    );
  }
}
