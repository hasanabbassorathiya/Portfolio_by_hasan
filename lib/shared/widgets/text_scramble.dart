import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class TextScramble extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration duration;
  final Duration delay;
  final TextAlign textAlign;

  const TextScramble({
    super.key,
    required this.text,
    this.style,
    this.duration = const Duration(milliseconds: 1500),
    this.delay = Duration.zero,
    this.textAlign = TextAlign.left,
  });

  @override
  State<TextScramble> createState() => _TextScrambleState();
}

class _TextScrambleState extends State<TextScramble> {
  String _display = '';
  final _random = Random();
  static const _chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#\$%^&*';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _display = _generateScrambled(widget.text.length);
    _startAfterDelay();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startAfterDelay() {
    Future.delayed(widget.delay, () {
      if (!mounted) return;
      _animateDecode();
    });
  }

  String _generateScrambled(int length) {
    return List.generate(
      length,
      (i) => widget.text[i] == ' ' ? ' ' : _chars[_random.nextInt(_chars.length)],
    ).join();
  }

  void _animateDecode() {
    var currentTick = 0;

    _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      currentTick++;
      final progress = currentTick * 30 / widget.duration.inMilliseconds;

      final buffer = StringBuffer();
      var spaceCount = 0;
      for (var i = 0; i < widget.text.length; i++) {
        if (widget.text[i] == ' ') {
          spaceCount++;
          buffer.write(' ');
          continue;
        }

        final charIndex = i - spaceCount;
        final totalNonSpace = widget.text.length - _countSpaces(widget.text);
        final charProgress = charIndex / totalNonSpace;

        if (progress > charProgress + 0.1) {
          buffer.write(widget.text[i]);
        } else if (progress > charProgress - 0.05) {
          buffer.write(_random.nextBool() ? widget.text[i] : _chars[_random.nextInt(_chars.length)]);
        } else {
          buffer.write(_chars[_random.nextInt(_chars.length)]);
        }
      }

      setState(() => _display = buffer.toString());

      if (progress >= 1.0) {
        timer.cancel();
        setState(() => _display = widget.text);
      }
    });
  }

  int _countSpaces(String s) {
    var count = 0;
    for (var i = 0; i < s.length; i++) {
      if (s[i] == ' ') count++;
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _display,
      style: widget.style,
      textAlign: widget.textAlign,
    );
  }
}
