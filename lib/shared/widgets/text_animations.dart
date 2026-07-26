import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../core/theme/app_colors.dart';

class TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration speed;
  final Duration startDelay;
  final String cursorChar;
  final bool showCursor;
  final VoidCallback? onComplete;

  const TypewriterText({
    super.key,
    required this.text,
    this.style,
    this.speed = const Duration(milliseconds: 60),
    this.startDelay = Duration.zero,
    this.cursorChar = '|',
    this.showCursor = true,
    this.onComplete,
  });

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText>
    with SingleTickerProviderStateMixin {
  String _displayed = '';
  bool _started = false;
  int _charIndex = 0;
  late AnimationController _cursorBlink;

  @override
  void initState() {
    super.initState();
    _cursorBlink = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 530),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _cursorBlink.dispose();
    super.dispose();
  }

  void _startTyping() {
    if (_started) return;
    _started = true;

    Future.delayed(widget.startDelay, () {
      _typeNextChar();
    });
  }

  void _typeNextChar() {
    if (!mounted || _charIndex >= widget.text.length) {
      if (_charIndex >= widget.text.length && mounted) {
        widget.onComplete?.call();
      }
      return;
    }

    setState(() {
      _displayed += widget.text[_charIndex];
      _charIndex++;
    });

    Future.delayed(widget.speed, _typeNextChar);
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('typewriter_${widget.key ?? widget.hashCode}'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.2) _startTyping();
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              _displayed,
              style: widget.style,
            ),
          ),
          if (widget.showCursor)
            FadeTransition(
              opacity: _cursorBlink,
              child: Text(
                widget.cursorChar,
                style: widget.style?.copyWith(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class CountUp extends StatefulWidget {
  final int end;
  final Duration duration;
  final TextStyle? style;
  final String suffix;
  final String prefix;

  const CountUp({
    super.key,
    required this.end,
    this.duration = const Duration(milliseconds: 2000),
    this.style,
    this.suffix = '',
    this.prefix = '',
  });

  @override
  State<CountUp> createState() => _CountUpState();
}

class _CountUpState extends State<CountUp>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = Tween<double>(begin: 0, end: widget.end.toDouble())
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('countup_${widget.key ?? widget.hashCode}'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.2 && !_started) {
          _started = true;
          _controller.forward();
        }
      },
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, _) {
          return Text(
            '${widget.prefix}${_animation.value.toInt()}${widget.suffix}',
            style: widget.style,
          );
        },
      ),
    );
  }
}

class SlideInText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration duration;
  final Duration delay;

  const SlideInText({
    super.key,
    required this.text,
    this.style,
    this.duration = const Duration(milliseconds: 800),
    this.delay = Duration.zero,
  });

  @override
  State<SlideInText> createState() => _SlideInTextState();
}

class _SlideInTextState extends State<SlideInText> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('slidein_${widget.key ?? widget.hashCode}'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.2 && !_visible) {
          setState(() => _visible = true);
        }
      },
      child: AnimatedSlide(
        offset: _visible ? Offset.zero : const Offset(0, 0.3),
        duration: widget.duration,
        curve: Curves.easeOutCubic,
        child: AnimatedOpacity(
          opacity: _visible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 400),
          child: Text(widget.text, style: widget.style),
        ),
      ),
    );
  }
}
