import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/database/portfolio_repository.dart';
import '../../../shared/widgets/scroll_reveal.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/layouts/section_wrapper.dart';

class ServicesSection extends StatelessWidget {
  const ServicesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final isMobile = w < 600;
    final isTablet = w < 1200;
    final services = PortfolioRepository().services;

    return Container(
      color: AppColors.deep,
      child: SectionWrapper(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ScrollReveal(
              child: const EyebrowTag(label: 'Services'),
            ),
            const SizedBox(height: 32),
            ScrollReveal(
              delay: const Duration(milliseconds: 120),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: const Text(
                  'What I build.',
                  style: TextStyle(
                    fontSize: 52,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                    height: 1.05,
                    letterSpacing: -1.8,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ScrollReveal(
              delay: const Duration(milliseconds: 200),
              child: Text(
                'End-to-end mobile and web solutions, from architecture to deployment.',
                style: TextStyle(
                  fontSize: isMobile ? 15 : 17,
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: 64),
            if (isMobile)
              Column(
                children: List.generate(services.length, (i) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: ScrollReveal(
                      delay: Duration(milliseconds: 100 * i),
                      child: _ServiceCard(service: services[i]),
                    ),
                  );
                }),
              )
            else
              _buildAsymBento(isTablet, services),
          ],
        ),
      ),
    );
  }

  /// Asymmetrical masonry: first card spans the full left half and two
  /// rows of the right column, breaking the symmetric 3-column monotony.
  Widget _buildAsymBento(bool isTablet, List<Map<String, dynamic>> services) {
    if (services.isEmpty) return const SizedBox.shrink();
    final cols = isTablet ? 2 : 2; // wide left col + stacked right col
    void _;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 5,
            child: ScrollReveal(
              direction: RevealDirection.left,
              child: _ServiceCard(service: services[0], featured: true),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: cols >= 2 ? 5 : 3,
            child: Column(
              children: [
                if (services.length > 1)
                  Expanded(
                    child: ScrollReveal(
                      direction: RevealDirection.right,
                      delay: const Duration(milliseconds: 150),
                      child: _ServiceCard(service: services[1]),
                    ),
                  ),
                if (services.length > 1) const SizedBox(height: 24),
                if (services.length > 2)
                  Expanded(
                    child: ScrollReveal(
                      direction: RevealDirection.right,
                      delay: const Duration(milliseconds: 300),
                      child: _ServiceCard(service: services[2]),
                    ),
                  ),
              ],
            ),
          ),
          if (services.length > 3 && !isTablet) ...[
            const SizedBox(width: 24),
            Expanded(
              flex: 4,
              child: Column(
                children: [
                  Expanded(
                    child: ScrollReveal(
                      direction: RevealDirection.right,
                      delay: const Duration(milliseconds: 450),
                      child: _ServiceCard(service: services[3]),
                    ),
                  ),
                  if (services.length > 4) ...[
                    const SizedBox(height: 24),
                    Expanded(
                      child: ScrollReveal(
                        direction: RevealDirection.right,
                        delay: const Duration(milliseconds: 600),
                        child: _ServiceCard(service: services[4]),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ServiceCard extends StatefulWidget {
  final Map<String, dynamic> service;
  final bool featured;

  const _ServiceCard({required this.service, this.featured = false});

  @override
  State<_ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<_ServiceCard> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final rawCodepoint = widget.service['icon_codepoint'];
    final iconCodepoint = rawCodepoint is int
        ? rawCodepoint
        : int.tryParse(rawCodepoint?.toString() ?? '') ?? 0;

    // DB-driven Material codepoints are honored for backward compatibility;
    // all defaults fall back to Phosphor Light.
    final Widget icon = iconCodepoint != 0
        ? Icon(
            IconData(iconCodepoint, fontFamily: 'MaterialIcons'),
            color: _hovered ? AppColors.accent : AppColors.textSecondary,
            size: 26,
          )
        : PhosphorIcon(
            PhosphorIconsLight.sparkle,
            color: _hovered ? AppColors.accent : AppColors.textSecondary,
            size: 26,
          );

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedContainer(
          duration: AppMotion.slow,
          curve: AppMotion.settle,
          padding: const EdgeInsets.all(6),
          transform: _pressed
              ? (Matrix4.identity()..scale(0.985, 0.985))
              : (_hovered
                  ? (Matrix4.identity()..translate(0.0, -3.0))
                  : Matrix4.identity()),
          transformAlignment: Alignment.center,
          decoration: BoxDecoration(
            color: _hovered ? AppColors.white08 : AppColors.glassFill,
            border: Border.all(
              color: _hovered
                  ? AppColors.accent.withValues(alpha: 0.45)
                  : AppColors.hairline,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(AppSpacing.radiusShell),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.12),
                      offset: const Offset(0, 20),
                      blurRadius: 70,
                    ),
                  ]
                : AppColors.shadowAmbient,
          ),
          child: Container(
            padding: EdgeInsets.all(widget.featured ? 36 : 28),
            decoration: BoxDecoration(
              color: _hovered ? AppColors.surface : AppColors.base,
              borderRadius: BorderRadius.circular(AppSpacing.radiusCore),
              border: const Border(
                top: BorderSide(color: Color(0x21FFFFFF), width: 1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.glassFill,
                    border: Border.all(color: AppColors.hairline, width: 1),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: icon,
                ),
                const SizedBox(height: 24),
                Text(
                  (widget.service['title'] ?? '') as String,
                  style: TextStyle(
                    fontSize: widget.featured ? 24 : 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  (widget.service['description'] ?? '') as String,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.7,
                  ),
                ),
                const SizedBox(height: 20),
                AnimatedSlide(
                  offset: _hovered ? Offset.zero : const Offset(-0.4, 0),
                  duration: AppMotion.fast,
                  curve: AppMotion.swiftOut,
                  child: AnimatedOpacity(
                    opacity: _hovered ? 1.0 : 0.0,
                    duration: AppMotion.fast,
                    child: Row(
                      children: [
                        Text(
                          'LEARN MORE',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.accent,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Transform.rotate(
                          angle: -0.7853981634,
                          child: PhosphorIcon(
                            PhosphorIconsLight.arrowRight,
                            size: 14,
                            color: AppColors.accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
