import 'package:flutter/material.dart';

class MagneticCursor extends StatefulWidget {
  final Widget child;
  final double strength;
  final double radius;

  const MagneticCursor({
    super.key,
    required this.child,
    this.strength = 0.3,
    this.radius = 100,
  });

  @override
  State<MagneticCursor> createState() => _MagneticCursorState();
}

class _MagneticCursorState extends State<MagneticCursor> {
  Offset _offset = Offset.zero;
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) {
        setState(() {
          _hovering = false;
          _offset = Offset.zero;
        });
      },
      onHover: (event) {
        if (!_hovering) return;
        final box = context.findRenderObject() as RenderBox?;
        if (box == null) return;
        final center = Offset(box.size.width / 2, box.size.height / 2);
        final delta = event.localPosition - center;
        final distance = delta.distance;
        if (distance < widget.radius) {
          final factor = (1 - distance / widget.radius) * widget.strength;
          setState(() => _offset = delta * factor);
        } else {
          setState(() => _offset = Offset.zero);
        }
      },
      child: Transform.translate(offset: _offset, child: widget.child),
    );
  }
}
