import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class CursorTrail extends StatefulWidget {
  final Widget child;
  final int trailLength;
  final Color color;

  const CursorTrail({
    super.key,
    required this.child,
    this.trailLength = 12,
    this.color = AppColors.accent,
  });

  @override
  State<CursorTrail> createState() => _CursorTrailState();
}

class _CursorTrailState extends State<CursorTrail> {
  final List<Offset> _points = [];

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerMove: (event) {
        setState(() {
          _points.add(event.position);
          if (_points.length > widget.trailLength) {
            _points.removeAt(0);
          }
        });
      },
      onPointerHover: (event) {
        setState(() {
          _points.add(event.position);
          if (_points.length > widget.trailLength) {
            _points.removeAt(0);
          }
        });
      },
      child: Stack(
        children: [
          widget.child,
          if (_points.isNotEmpty)
            IgnorePointer(
              child: CustomPaint(
                painter: _TrailPainter(
                  points: _points,
                  color: widget.color,
                ),
                size: Size.infinite,
              ),
            ),
        ],
      ),
    );
  }
}

class _TrailPainter extends CustomPainter {
  final List<Offset> points;
  final Color color;

  _TrailPainter({required this.points, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    for (var i = 1; i < points.length; i++) {
      final progress = i / points.length;
      final opacity = progress * 0.4;
      final width = progress * 3;

      canvas.drawLine(
        points[i - 1],
        points[i],
        Paint()
          ..color = color.withValues(alpha: opacity)
          ..strokeWidth = width
          ..strokeCap = StrokeCap.round,
      );
    }

    if (points.isNotEmpty) {
      final last = points.last;
      canvas.drawCircle(
        last,
        4,
        Paint()..color = color.withValues(alpha: 0.6),
      );
      canvas.drawCircle(
        last,
        12,
        Paint()..color = color.withValues(alpha: 0.1),
      );
    }
  }

  @override
  bool shouldRepaint(_TrailPainter old) => true;
}
