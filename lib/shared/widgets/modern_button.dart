import 'package:flutter/material.dart';
import 'package:portfolio/shared/constants/colors.dart';
import 'package:portfolio/shared/constants/design_tokens.dart';
import 'package:portfolio/shared/constants/textstyles.dart';
import 'package:portfolio/shared/widgets/custom_cursor.dart';

/// Modern button component with gradient and smooth animations
/// Based on Figma design with hover effects and transitions
class ModernButton extends StatefulWidget {
  final String title;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool isLoading;
  final ButtonVariant variant;
  final double? width;
  final EdgeInsets? padding;

  const ModernButton({
    super.key,
    required this.title,
    this.icon,
    this.onTap,
    this.isLoading = false,
    this.variant = ButtonVariant.primary,
    this.width,
    this.padding,
  });

  @override
  State<ModernButton> createState() => _ModernButtonState();
}

enum ButtonVariant { primary, secondary, outline }

class _ModernButtonState extends State<ModernButton>
    with SingleTickerProviderStateMixin {
  bool _isHovering = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap?.call();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isPrimary = widget.variant == ButtonVariant.primary;
    final isSecondary = widget.variant == ButtonVariant.secondary;
    final isOutline = widget.variant == ButtonVariant.outline;

    return CursorAware(
      onHover: () {
        setState(() {
          _isHovering = true;
        });
        _controller.forward();
      },
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: widget.onTap,
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
                  padding:
                      widget.padding ??
                      const EdgeInsets.symmetric(
                        horizontal: DesignTokens.buttonPaddingHorizontal,
                        vertical: DesignTokens.buttonPaddingVertical,
                      ),
                  decoration: BoxDecoration(
                    gradient:
                        isPrimary || isSecondary
                            ? (_isHovering
                                ? AppColors.primaryGradient
                                : AppColors.primaryGradient)
                            : null,
                    color:
                        isOutline
                            ? Colors.transparent
                            : (_isHovering ? null : AppColors.primary),
                    borderRadius: BorderRadius.circular(
                      DesignTokens.borderRadius0,
                    ),
                    border:
                        isOutline
                            ? Border.all(color: AppColors.primary, width: 1.5)
                            : null,
                    boxShadow:
                        _isHovering
                            ? [
                              BoxShadow(
                                color: AppColors.gradientOrange.withOpacity(
                                  0.3 * _glowAnimation.value,
                                ),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                              BoxShadow(
                                color: AppColors.gradientPurple.withOpacity(
                                  0.2 * _glowAnimation.value,
                                ),
                                blurRadius: 30,
                                spreadRadius: 1,
                              ),
                            ]
                            : [],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.isLoading)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      else ...[
                        Text(
                          widget.title,
                          style: AppStyles.button(
                            color: isOutline ? AppColors.primary : Colors.white,
                            context: context,
                          ),
                        ),
                        if (widget.icon != null) ...[
                          const SizedBox(width: DesignTokens.space8),
                          Icon(
                            widget.icon,
                            size: DesignTokens.iconSize24,
                            color: isOutline ? AppColors.primary : Colors.white,
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
