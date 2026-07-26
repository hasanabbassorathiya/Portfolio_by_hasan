import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../core/theme/app_colors.dart';

class KineticDivider extends StatefulWidget {
  final String text;
  final bool showLine;

  const KineticDivider({
    super.key,
    required this.text,
    this.showLine = true,
  });

  @override
  State<KineticDivider> createState() => _KineticDividerState();
}

class _KineticDividerState extends State<KineticDivider>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnim;
  late Animation<double> _opacityAnim;
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _slideAnim = Tween<double>(begin: -1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _opacityAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.3, 1.0)),
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
      key: Key('kinetic_div_${widget.key ?? widget.hashCode}'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.2 && !_visible) {
          _visible = true;
          _controller.forward();
        }
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Opacity(
            opacity: _opacityAnim.value,
            child: Transform.translate(
              offset: Offset(_slideAnim.value * 60, 0),
              child: child,
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Column(
            children: [
              if (widget.showLine) ...[
                Container(
                  height: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        AppColors.accent.withValues(alpha: 0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Text(
                widget.text.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 8,
                  color: AppColors.accent.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
