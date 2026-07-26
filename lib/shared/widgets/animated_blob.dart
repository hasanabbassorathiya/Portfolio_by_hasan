import 'dart:math';
import 'package:flutter/material.dart';

class AnimatedBlob extends StatefulWidget {
  final double size;
  final Color color;
  final Offset initialPosition;
  final Duration duration;

  const AnimatedBlob({
    super.key,
    required this.size,
    required this.color,
    required this.initialPosition,
    this.duration = const Duration(seconds: 8),
  });

  @override
  State<AnimatedBlob> createState() => _AnimatedBlobState();
}

class _AnimatedBlobState extends State<AnimatedBlob>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true);

    final rng = Random(widget.initialPosition.hashCode);
    _offsetAnimation = Tween<Offset>(
      begin: widget.initialPosition,
      end: widget.initialPosition + Offset(rng.nextDouble() * 40 - 20, rng.nextDouble() * 40 - 20),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
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
      builder: (context, child) {
        return Transform.translate(
          offset: _offsetAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [widget.color, Colors.transparent],
                  stops: const [0.3, 1.0],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
