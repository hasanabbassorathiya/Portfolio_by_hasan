/// Typewriter text widget
/// Displays text character by character with a blinking cursor
import 'package:flutter/material.dart';

class TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration speed;
  final Duration cursorBlinkSpeed;
  final String cursor;
  final bool restartOnRebuild;

  const TypewriterText({
    super.key,
    required this.text,
    this.style,
    this.speed = const Duration(milliseconds: 50),
    this.cursorBlinkSpeed = const Duration(milliseconds: 500),
    this.cursor = '|',
    this.restartOnRebuild = false,
  });

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _cursorController;
  late Animation<double> _cursorAnimation;
  int _currentLength = 0;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
  }

  @override
  void didUpdateWidget(TypewriterText oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Restart animation if text changed or restartOnRebuild is true
    if (widget.text != oldWidget.text || 
        (widget.restartOnRebuild && !oldWidget.restartOnRebuild)) {
      _resetAndStart();
    }
  }

  void _initializeAnimation() {
    // Controller for typewriter effect
    _controller = AnimationController(
      vsync: this,
      duration: widget.speed,
    );

    // Controller for cursor blinking
    _cursorController = AnimationController(
      vsync: this,
      duration: widget.cursorBlinkSpeed,
    );

    _cursorAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_cursorController);

    _cursorController.repeat(reverse: true);

    // Start typing animation
    _startTyping();
  }

  void _resetAndStart() {
    _currentLength = 0;
    _controller.reset();
    _cursorController.reset();
    _cursorController.repeat(reverse: true);
    _startTyping();
  }

  void _startTyping() {
    if (widget.text.isEmpty) return;

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (_currentLength < widget.text.length) {
          setState(() {
            _currentLength++;
          });
          _controller.reset();
          _controller.forward();
        } else {
          // Typing complete, keep cursor blinking
          _cursorController.repeat(reverse: true);
        }
      }
    });

    // Start the animation
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _cursorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayedText = widget.text.substring(
      0,
      _currentLength.clamp(0, widget.text.length),
    );

    return AnimatedBuilder(
      animation: _cursorAnimation,
      builder: (context, child) {
        final cursorOpacity = _currentLength < widget.text.length
            ? 1.0
            : _cursorAnimation.value;

        return RichText(
          text: TextSpan(
            style: widget.style,
            children: [
              TextSpan(text: displayedText),
              if (_currentLength < widget.text.length || cursorOpacity > 0.5)
                TextSpan(
                  text: widget.cursor,
                  style: (widget.style ?? const TextStyle()).copyWith(
                    color: (widget.style?.color ?? Colors.black)
                        .withOpacity(cursorOpacity),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

