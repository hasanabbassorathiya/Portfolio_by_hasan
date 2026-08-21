import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/database/portfolio_repository.dart';
import '../../../shared/widgets/scroll_reveal.dart';
import '../../../shared/layouts/section_wrapper.dart';

class TestimonialsSection extends StatelessWidget {
  const TestimonialsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final isMobile = w < 600;
    final testimonials = PortfolioRepository().testimonials;

    return SectionWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ScrollReveal(
            direction: RevealDirection.up,
            child: Row(
              children: [
                Container(width: 32, height: 2, color: AppColors.accent),
                const SizedBox(width: 16),
                Text('TESTIMONIALS', style: AppTypography.label()),
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
                'What they say.',
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
          const SizedBox(height: 64),
          if (isMobile)
            Column(
              children: List.generate(testimonials.length, (i) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: ScrollReveal(
                    direction: RevealDirection.up,
                    delay: Duration(milliseconds: 150 * i),
                    child: IntrinsicHeight(
                      child: _TestimonialCard(testimonial: testimonials[i]),
                    ),
                  ),
                );
              }),
            )
          else
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(testimonials.length, (i) {
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: i < testimonials.length - 1 ? 16 : 0,
                      ),
                      child: ScrollReveal(
                        direction:
                            i.isEven ? RevealDirection.left : RevealDirection.right,
                        delay: Duration(milliseconds: 200 * i),
                        child: _TestimonialCard(testimonial: testimonials[i]),
                      ),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}

class _TestimonialCard extends StatefulWidget {
  final Map<String, dynamic> testimonial;

  const _TestimonialCard({required this.testimonial});

  @override
  State<_TestimonialCard> createState() => _TestimonialCardState();
}

class _TestimonialCardState extends State<_TestimonialCard> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.testimonial;
    final clientName = (t['clientName'] ?? t['client_name'] ?? '') as String;
    final clientRole = (t['clientRole'] ?? t['client_role'] ?? '') as String;
    final clientCompany = (t['clientCompany'] ?? t['client_company'] ?? '') as String;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
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
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: AppColors.accent,
                ),
                child: const Icon(
                  Icons.format_quote,
                  color: AppColors.deep,
                  size: 18,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Text(
                  (t['quote'] ?? '') as String,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.7,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                height: 2,
                color: AppColors.border,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: AppColors.accent,
                    ),
                    child: Center(
                      child: Text(
                        clientName.isNotEmpty ? clientName[0] : '?',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: AppColors.deep,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          clientName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '$clientRole · $clientCompany',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
