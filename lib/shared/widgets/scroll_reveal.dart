import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

enum RevealDirection { up, down, left, right, scale, fade }

class ScrollReveal extends StatefulWidget {
  final Widget child;
  final RevealDirection direction;
  final Duration duration;
  final Duration delay;
  final double offset;

  const ScrollReveal({
    super.key,
    required this.child,
    this.direction = RevealDirection.up,
    this.duration = const Duration(milliseconds: 600),
    this.delay = Duration.zero,
    this.offset = 40,
  });

  @override
  State<ScrollReveal> createState() => _ScrollRevealState();
}

class _ScrollRevealState extends State<ScrollReveal>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('reveal_${widget.key ?? widget.hashCode}'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.15 && !_visible) {
          _visible = true;
          Future.delayed(widget.delay, () {
            if (mounted) _controller.forward();
          });
        }
      },
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final t = _animation.value;
          Offset offset;
          double scale;

          switch (widget.direction) {
            case RevealDirection.up:
              offset = Offset(0, widget.offset * (1 - t));
              scale = 1.0;
            case RevealDirection.down:
              offset = Offset(0, -widget.offset * (1 - t));
              scale = 1.0;
            case RevealDirection.left:
              offset = Offset(widget.offset * (1 - t), 0);
              scale = 1.0;
            case RevealDirection.right:
              offset = Offset(-widget.offset * (1 - t), 0);
              scale = 1.0;
            case RevealDirection.scale:
              offset = Offset.zero;
              scale = 0.85 + (0.15 * t);
            case RevealDirection.fade:
              offset = Offset.zero;
              scale = 1.0;
          }

          return Transform.translate(
            offset: offset,
            child: Transform.scale(
              scale: scale,
              child: Opacity(
                opacity: t,
                child: child,
              ),
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}

class StaggerReveal extends StatelessWidget {
  final List<Widget> children;
  final RevealDirection direction;
  final Duration baseDuration;
  final Duration staggerDelay;

  const StaggerReveal({
    super.key,
    required this.children,
    this.direction = RevealDirection.up,
    this.baseDuration = const Duration(milliseconds: 600),
    this.staggerDelay = const Duration(milliseconds: 100),
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(children.length, (i) {
        return ScrollReveal(
          key: ValueKey('stagger_${key}_$i'),
          direction: direction,
          duration: baseDuration,
          delay: staggerDelay * i,
          child: children[i],
        );
      }),
    );
  }
}
