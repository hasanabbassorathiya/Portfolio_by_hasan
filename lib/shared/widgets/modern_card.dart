import 'package:flutter/material.dart';
import 'package:portfolio/shared/constants/colors.dart';
import 'package:portfolio/shared/constants/design_tokens.dart';
import 'package:portfolio/shared/widgets/custom_cursor.dart';

/// Modern card component with hover effects and smooth animations
/// Based on Figma design with gradient borders and shadows
class ModernCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final bool showGradientBorder;
  final double? width;
  final double? height;

  const ModernCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.backgroundColor,
    this.showGradientBorder = false,
    this.width,
    this.height,
  });

  @override
  State<ModernCard> createState() => _ModernCardState();
}

class _ModernCardState extends State<ModernCard>
    with SingleTickerProviderStateMixin {
  bool _isHovering = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _elevationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CursorAware(
      onTap: widget.onTap,
      onHover: () {
        setState(() {
          _isHovering = true;
        });
        _controller.forward();
      },
      child: MouseRegion(
        onExit: (_) {
          setState(() {
            _isHovering = false;
          });
          _controller.reverse();
        },
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: widget.width,
                height: widget.height,
                padding:
                    widget.padding ??
                    const EdgeInsets.all(DesignTokens.space24),
                decoration: BoxDecoration(
                  color: widget.backgroundColor ?? AppColors.bgColor,
                  borderRadius: BorderRadius.circular(
                    DesignTokens.borderRadius12,
                  ),
                  border:
                      widget.showGradientBorder && _isHovering
                          ? Border.all(width: 2, color: Colors.transparent)
                          : Border.all(color: AppColors.borderDark, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(
                        0.05 + (0.1 * _elevationAnimation.value),
                      ),
                      blurRadius: 20 + (10 * _elevationAnimation.value),
                      offset: Offset(0, 5 + (5 * _elevationAnimation.value)),
                    ),
                    if (_isHovering)
                      BoxShadow(
                        color: AppColors.gradientOrange.withOpacity(
                          0.2 * _elevationAnimation.value,
                        ),
                        blurRadius: 30,
                        spreadRadius: 2,
                      ),
                  ],
                ),
                child: widget.child,
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Gradient border card with animated gradient
class GradientCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets? padding;

  const GradientCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
  });

  @override
  State<GradientCard> createState() => _GradientCardState();
}

class _GradientCardState extends State<GradientCard>
    with SingleTickerProviderStateMixin {
  bool _isHovering = false;
  late AnimationController _controller;
  late Animation<double> _gradientAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _gradientAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CursorAware(
      onTap: widget.onTap,
      onHover: () {
        setState(() {
          _isHovering = true;
        });
      },
      child: MouseRegion(
        onExit: (_) {
          setState(() {
            _isHovering = false;
          });
        },
        child: AnimatedBuilder(
          animation: _gradientAnimation,
          builder: (context, child) {
            return Container(
              padding:
                  widget.padding ?? const EdgeInsets.all(DesignTokens.space24),
              decoration: BoxDecoration(
                gradient:
                    _isHovering
                        ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.gradientOrange,
                            AppColors.gradientRed,
                            AppColors.gradientPurple,
                          ],
                          stops: [
                            0.0,
                            0.5 + (0.1 * _gradientAnimation.value),
                            1.0,
                          ],
                        )
                        : null,
                color: _isHovering ? null : AppColors.bgColor,
                borderRadius: BorderRadius.circular(
                  DesignTokens.borderRadius12,
                ),
                boxShadow:
                    _isHovering
                        ? [
                          BoxShadow(
                            color: AppColors.gradientOrange.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ]
                        : [],
              ),
              child: widget.child,
            );
          },
        ),
      ),
    );
  }
}
