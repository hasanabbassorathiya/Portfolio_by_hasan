import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final bool hoverable;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.hoverable = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        width: width,
        height: height,
        margin: margin,
        padding: padding ?? const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.base,
          border: Border.all(color: AppColors.border, width: 2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x40000000),
              offset: Offset(4, 4),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
