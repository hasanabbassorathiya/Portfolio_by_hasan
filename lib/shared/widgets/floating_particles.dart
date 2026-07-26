import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class FloatingParticles extends StatefulWidget {
  final int count;
  final Color color;
  final double maxSize;
  final double speed;

  const FloatingParticles({
    super.key,
    this.count = 40,
    this.color = AppColors.accent,
    this.maxSize = 4,
    this.speed = 0.5,
  });

  @override
  State<FloatingParticles> createState() => _FloatingParticlesState();
}

class _FloatingParticlesState extends State<FloatingParticles>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    final rng = math.Random();
    _particles = List.generate(widget.count, (_) {
      return _Particle(
        x: rng.nextDouble(),
        y: rng.nextDouble(),
        size: 1 + rng.nextDouble() * (widget.maxSize - 1),
        speedX: (rng.nextDouble() - 0.5) * widget.speed * 0.01,
        speedY: -rng.nextDouble() * widget.speed * 0.005 - 0.002,
        opacity: 0.1 + rng.nextDouble() * 0.4,
        pulse: rng.nextDouble() * math.pi * 2,
        pulseSpeed: 0.5 + rng.nextDouble() * 1.5,
      );
    });

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..addListener(_tick);

    _controller.repeat();
  }

  void _tick() {
    for (final p in _particles) {
      p.x += p.speedX;
      p.y += p.speedY;
      p.pulse += p.pulseSpeed * 0.016;

      if (p.y < -0.05) {
        p.y = 1.05;
        p.x = math.Random().nextDouble();
      }
      if (p.x < -0.05) p.x = 1.05;
      if (p.x > 1.05) p.x = -0.05;
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ParticlePainter(
        particles: _particles,
        color: widget.color,
      ),
      size: Size.infinite,
    );
  }
}

class _Particle {
  double x, y, size, speedX, speedY, opacity, pulse, pulseSpeed;

  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speedX,
    required this.speedY,
    required this.opacity,
    required this.pulse,
    required this.pulseSpeed,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final Color color;

  _ParticlePainter({required this.particles, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final px = p.x * size.width;
      final py = p.y * size.height;
      final currentOpacity = p.opacity * (0.5 + 0.5 * math.sin(p.pulse));
      final currentSize = p.size * (0.8 + 0.2 * math.sin(p.pulse));

      canvas.drawCircle(
        Offset(px, py),
        currentSize,
        Paint()..color = color.withValues(alpha: currentOpacity),
      );

      if (currentSize > 2.5) {
        canvas.drawCircle(
          Offset(px, py),
          currentSize * 3,
          Paint()..color = color.withValues(alpha: currentOpacity * 0.15),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => true;
}
