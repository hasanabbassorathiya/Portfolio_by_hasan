import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class FloatingNav extends StatefulWidget {
  final int currentSection;
  final List<NavItem> items;
  final VoidCallback? onCtaPressed;

  const FloatingNav({
    super.key,
    required this.currentSection,
    required this.items,
    this.onCtaPressed,
  });

  @override
  State<FloatingNav> createState() => _FloatingNavState();
}

class NavItem {
  final String label;
  final VoidCallback onTap;

  const NavItem({required this.label, required this.onTap});
}

class _FloatingNavState extends State<FloatingNav> {
  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final isMobile = w < 1024;

    if (isMobile) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.base.withValues(alpha: 0.95),
        border: Border.all(color: AppColors.border, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            offset: Offset(4, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'HA',
              style: TextStyle(
                color: AppColors.accent,
                fontWeight: FontWeight.w900,
                fontSize: 18,
                letterSpacing: 2,
              ),
            ),
          ),
          const SizedBox(width: 8),
          ...List.generate(widget.items.length, (i) {
            final item = widget.items[i];
            final isActive = widget.currentSection == i;
            return GestureDetector(
              onTap: item.onTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.accent : Colors.transparent,
                  border: isActive ? Border.all(color: AppColors.accent, width: 2) : null,
                ),
                child: Text(
                  item.label.toUpperCase(),
                  style: TextStyle(
                    color: isActive ? AppColors.deep : AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                ),
              ),
            );
          }),
          const SizedBox(width: 8),
          if (widget.onCtaPressed != null)
            GestureDetector(
              onTap: widget.onCtaPressed,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                decoration: const BoxDecoration(color: AppColors.accent),
                child: const Text(
                  "LET'S TALK",
                  style: TextStyle(
                    color: AppColors.deep,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
