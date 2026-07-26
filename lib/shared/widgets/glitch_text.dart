import 'dart:math' as math;
import 'package:flutter/material.dart';

class GlitchText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration interval;
  final bool autoStart;

  const GlitchText({
    super.key,
    required this.text,
    this.style,
    this.interval = const Duration(seconds: 4),
    this.autoStart = true,
  });

  @override
  State<GlitchText> createState() => _GlitchTextState();
}

class _GlitchTextState extends State<GlitchText> {
  bool _glitching = false;
  late final math.Random _rng;

  @override
  void initState() {
    super.initState();
    _rng = math.Random();
    if (widget.autoStart) _startLoop();
  }

  void _startLoop() {
    Future.doWhile(() async {
      await Future.delayed(widget.interval);
      if (!mounted) return false;
      await _trigger();
      return true;
    });
  }

  Future<void> _trigger() async {
    if (!mounted) return;
    setState(() => _glitching = true);
    for (var i = 0; i < 3; i++) {
      await Future.delayed(const Duration(milliseconds: 80));
      if (!mounted) return;
      setState(() {});
    }
    if (mounted) setState(() => _glitching = false);
  }

  @override
  Widget build(BuildContext context) {
    final baseStyle = widget.style ?? const TextStyle();
    final display = _glitching ? _applyGlitch(widget.text) : widget.text;

    return Stack(
      children: [
        if (_glitching)
          Transform.translate(
            offset: const Offset(-2, 0),
            child: Text(
              display,
              style: baseStyle.copyWith(
                color: Colors.red.withValues(alpha: 0.7),
              ),
            ),
          ),
        if (_glitching)
          Transform.translate(
            offset: const Offset(2, 0),
            child: Text(
              display,
              style: baseStyle.copyWith(
                color: Colors.cyan.withValues(alpha: 0.7),
              ),
            ),
          ),
        Text(display, style: baseStyle),
      ],
    );
  }

  String _applyGlitch(String input) {
    const glitchChars = '!@#\$%^&*()_+-=[]{}|;:,.<>?/~`';
    final buffer = StringBuffer();
    for (var i = 0; i < input.length; i++) {
      if (_rng.nextDouble() < 0.3) {
        buffer.write(glitchChars[_rng.nextInt(glitchChars.length)]);
      } else {
        buffer.write(input[i]);
      }
    }
    return buffer.toString();
  }
}
