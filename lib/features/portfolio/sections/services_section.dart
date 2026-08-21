import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/database/portfolio_repository.dart';
import '../../../shared/widgets/scroll_reveal.dart';
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
              direction: RevealDirection.up,
              child: Row(
                children: [
                  Container(width: 32, height: 2, color: AppColors.accent),
                  const SizedBox(width: 16),
                  Text('SERVICES', style: AppTypography.label()),
                ],
              ),
            ),
            const SizedBox(height: 40),
            ScrollReveal(
              direction: RevealDirection.up,
              delay: const Duration(milliseconds: 200),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: Text(
                  'What I build.',
                  style: TextStyle(
                    fontSize: isMobile ? 36 : 52,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                    height: 1.1,
                    letterSpacing: -1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ScrollReveal(
              direction: RevealDirection.up,
              delay: const Duration(milliseconds: 300),
              child: Text(
                'End-to-end mobile and web solutions, from architecture to deployment.',
                style: AppTypography.body(),
              ),
            ),
            const SizedBox(height: 64),
            if (isMobile)
              Column(
                children: List.generate(services.length, (i) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: ScrollReveal(
                      direction: RevealDirection.up,
                      delay: Duration(milliseconds: 100 * i),
                      child: _ServiceCard(service: services[i]),
                    ),
                  );
                }),
              )
            else
              _buildBentoGrid(isTablet, services),
          ],
        ),
      ),
    );
  }

  Widget _buildBentoGrid(bool isTablet, List<Map<String, dynamic>> services) {
    final cols = isTablet ? 2 : 3;

    return Column(
      children: List.generate(
        (services.length / cols).ceil(),
        (rowIndex) {
          final startIdx = rowIndex * cols;
          final remaining = (services.length - startIdx).clamp(0, cols);

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(remaining, (colIdx) {
                final idx = startIdx + colIdx;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: colIdx < remaining - 1 ? 16 : 0),
                    child: ScrollReveal(
                      direction: RevealDirection.up,
                      delay: Duration(milliseconds: 100 * idx),
                      child: _ServiceCard(service: services[idx]),
                    ),
                  ),
                );
              }),
            ),
          );
        },
      ),
    );
  }
}

class _ServiceCard extends StatefulWidget {
  final Map<String, dynamic> service;

  const _ServiceCard({required this.service});

  @override
  State<_ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<_ServiceCard> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final iconCodepoint = (widget.service['icon_codepoint'] as int?) ?? 0;
    final iconData = iconCodepoint != 0
        ? IconData(iconCodepoint, fontFamily: 'MaterialIcons')
        : Icons.star_outline;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
          transform: _pressed
              ? (Matrix4.identity()..translate(2.0, 2.0))
              : Matrix4.identity(),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: _hovered ? AppColors.surface : AppColors.base,
            border: Border.all(
              color: _hovered ? AppColors.accent : AppColors.border,
              width: 2,
            ),
            boxShadow: [
              if (!_pressed && _hovered)
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.15),
                  offset: const Offset(4, 4),
                ),
              if (!_pressed && !_hovered)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  offset: const Offset(4, 4),
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: _hovered ? AppColors.accent.withValues(alpha: 0.1) : AppColors.surface,
                  border: Border.all(color: _hovered ? AppColors.accent : AppColors.border, width: 2),
                ),
                child: Icon(
                  iconData,
                  color: _hovered ? AppColors.accent : AppColors.textSecondary,
                  size: 24,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                (widget.service['title'] ?? '') as String,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Text(
                  (widget.service['description'] ?? '') as String,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AnimatedSlide(
                offset: _hovered ? Offset.zero : const Offset(-0.5, 0),
                duration: const Duration(milliseconds: 200),
                child: AnimatedOpacity(
                  opacity: _hovered ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 150),
                  child: Row(
                    children: [
                      Text(
                        'LEARN MORE →',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.accent,
                          letterSpacing: 1,
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
    );
  }
}
