import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class MorphingBlob extends StatefulWidget {
  final double size;
  final Color color;
  final int points;

  const MorphingBlob({
    super.key,
    this.size = 300,
    this.color = AppColors.accent,
    this.points = 8,
  });

  @override
  State<MorphingBlob> createState() => _MorphingBlobState();
}

class _MorphingBlobState extends State<MorphingBlob>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          painter: _BlobPainter(
            progress: _controller.value,
            color: widget.color,
            points: widget.points,
            seed: 42,
          ),
          size: Size(widget.size, widget.size),
        );
      },
    );
  }
}

class _BlobPainter extends CustomPainter {
  final double progress;
  final Color color;
  final int points;
  final int seed;

  _BlobPainter({
    required this.progress,
    required this.color,
    required this.points,
    required this.seed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 * 0.7;
    final rng = math.Random(seed);
    final time = progress * 2 * math.pi;

    final path = Path();
    final angles = List.generate(points, (i) => (2 * math.pi * i) / points);

    final offsets = angles.map((angle) {
      final variation = 0.15 * math.sin(time + rng.nextDouble() * math.pi * 2);
      final r = radius * (1 + variation);
      return Offset(
        center.dx + r * math.cos(angle),
        center.dy + r * math.sin(angle),
      );
    }).toList();

    path.moveTo(offsets[0].dx, offsets[0].dy);

    for (var i = 0; i < offsets.length; i++) {
      final current = offsets[i];
      final next = offsets[(i + 1) % offsets.length];

      final cp1x = current.dx + (next.dx - offsets[(i - 1 + offsets.length) % offsets.length].dx) * 0.25;
      final cp1y = current.dy + (next.dy - offsets[(i - 1 + offsets.length) % offsets.length].dy) * 0.25;
      final cp2x = next.dx - (offsets[(i + 2) % offsets.length].dx - current.dx) * 0.25;
      final cp2y = next.dy - (offsets[(i + 2) % offsets.length].dy - current.dy) * 0.25;

      path.cubicTo(cp1x, cp1y, cp2x, cp2y, next.dx, next.dy);
    }

    path.close();

    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: 0.2),
          color.withValues(alpha: 0.05),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawPath(path, paint);

    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: 0.08),
          color.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 1.3));

    canvas.drawCircle(center, radius * 1.3, glowPaint);
  }

  @override
  bool shouldRepaint(_BlobPainter old) => true;
}

class ParallaxLayer extends StatefulWidget {
  final Widget child;
  final double speed;
  final double direction;

  const ParallaxLayer({
    super.key,
    required this.child,
    this.speed = 0.5,
    this.direction = 0,
  });

  @override
  State<ParallaxLayer> createState() => _ParallaxLayerState();
}

class _ParallaxLayerState extends State<ParallaxLayer> {
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupScrollListener();
    });
  }

  void _setupScrollListener() {
    final scrollable = Scrollable.of(context);
    scrollable.position.addListener(() {
      setState(() {
        _scrollOffset = scrollable.position.pixels;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final offset = _scrollOffset * widget.speed;

    return Transform.translate(
      offset: Offset(
        math.cos(widget.direction) * offset,
        math.sin(widget.direction) * offset,
      ),
      child: widget.child,
    );
  }
}

class GlowLine extends StatefulWidget {
  final double width;
  final double height;
  final Color color;
  final bool animate;

  const GlowLine({
    super.key,
    this.width = 200,
    this.height = 2,
    this.color = AppColors.accent,
    this.animate = true,
  });

  @override
  State<GlowLine> createState() => _GlowLineState();
}

class _GlowLineState extends State<GlowLine>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    if (widget.animate) _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                widget.color.withValues(alpha: 0.0),
                widget.color.withValues(alpha: 0.8),
                widget.color.withValues(alpha: 0.0),
              ],
              stops: [
                ((_controller.value - 0.3).clamp(0.0, 1.0)),
                _controller.value,
                ((_controller.value + 0.3).clamp(0.0, 1.0)),
              ],
            ),
            borderRadius: BorderRadius.circular(widget.height / 2),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.3),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
        );
      },
    );
  }
}
