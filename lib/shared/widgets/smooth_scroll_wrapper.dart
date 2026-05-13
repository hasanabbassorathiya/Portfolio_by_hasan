import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

/// Smooth scroll wrapper with enhanced physics and animations
class SmoothScrollWrapper extends StatelessWidget {
  final Widget child;
  final ScrollController? controller;
  final bool enableSmoothScroll;

  const SmoothScrollWrapper({
    super.key,
    required this.child,
    this.controller,
    this.enableSmoothScroll = true,
  });

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: _SmoothScrollBehavior(),
      child: SingleChildScrollView(
        controller: controller,
        physics:
            enableSmoothScroll
                ? const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics())
                : const ClampingScrollPhysics(),
        child: child,
      ),
    );
  }
}

class _SmoothScrollBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
  }
}

/// Animated section wrapper for smooth fade-in on scroll
class AnimatedSection extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Curve curve;

  const AnimatedSection({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.curve = Curves.easeOut,
  });

  @override
  State<AnimatedSection> createState() => _AnimatedSectionState();
}

class _AnimatedSectionState extends State<AnimatedSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    // Delay animation
    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(position: _slideAnimation, child: widget.child),
    );
  }
}
