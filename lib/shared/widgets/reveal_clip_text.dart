import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

class RevealClipText extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;

  const RevealClipText({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1000),
    this.delay = Duration.zero,
  });

  @override
  State<RevealClipText> createState() => _RevealClipTextState();
}

class _RevealClipTextState extends State<RevealClipText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _clipAnimation;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _clipAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('revealclip_${widget.key ?? widget.hashCode}'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.2 && !_started) {
          _started = true;
          Future.delayed(widget.delay, () {
            if (mounted) _controller.forward();
          });
        }
      },
      child: AnimatedBuilder(
        animation: _clipAnimation,
        builder: (context, child) {
          return ClipRect(
            clipper: _RevealClipper(_clipAnimation.value),
            child: widget.child,
          );
        },
      ),
    );
  }
}

class _RevealClipper extends CustomClipper<Rect> {
  final double progress;

  _RevealClipper(this.progress);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, size.width * progress, size.height);
  }

  @override
  bool shouldReclip(_RevealClipper oldDelegate) => oldDelegate.progress != progress;
}

class HorizontalRevealClipText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration duration;
  final Duration delay;
  final bool fromRight;

  const HorizontalRevealClipText({
    super.key,
    required this.text,
    this.style,
    this.duration = const Duration(milliseconds: 1000),
    this.delay = Duration.zero,
    this.fromRight = false,
  });

  @override
  State<HorizontalRevealClipText> createState() =>
      _HorizontalRevealClipTextState();
}

class _HorizontalRevealClipTextState extends State<HorizontalRevealClipText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('hreveal_${widget.key ?? widget.hashCode}'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.2 && !_started) {
          _started = true;
          Future.delayed(widget.delay, () {
            if (mounted) _controller.forward();
          });
        }
      },
      child: AnimatedBuilder(
        animation: CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(
              widget.fromRight ? 30 * (1 - _controller.value) : -30 * (1 - _controller.value),
              0,
            ),
            child: Opacity(
              opacity: _controller.value,
              child: Text(widget.text, style: widget.style),
            ),
          );
        },
      ),
    );
  }
}
