import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/database/portfolio_repository.dart';
import '../../../shared/widgets/scroll_reveal.dart';
import '../../../shared/layouts/section_wrapper.dart';

class ExperienceSection extends StatelessWidget {
  const ExperienceSection({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final isMobile = w < 600;
    final experiences = PortfolioRepository().experience;

    return Container(
      color: AppColors.base,
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
                  Text('EXPERIENCE', style: AppTypography.label()),
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
                  'Where I have been.',
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
            ...List.generate(experiences.length, (index) {
              final exp = experiences[index];
              final isLast = index == experiences.length - 1;
              return ScrollReveal(
                direction: RevealDirection.up,
                delay: Duration(milliseconds: 150 * index),
                child: _TimelineItem(
                  experience: exp,
                  isLast: isLast,
                  isMobile: isMobile,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _TimelineItem extends StatefulWidget {
  final Map<String, dynamic> experience;
  final bool isLast;
  final bool isMobile;

  const _TimelineItem({
    required this.experience,
    required this.isLast,
    required this.isMobile,
  });

  @override
  State<_TimelineItem> createState() => _TimelineItemState();
}

class _TimelineItemState extends State<_TimelineItem> {
  bool _expanded = false;
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final rawHighlights = widget.experience['highlights'];
    final highlights = rawHighlights is List ? rawHighlights : [];
    final startDate = (widget.experience['start_date'] ?? widget.experience['startDate'] ?? '') as String;
    final endDate = (widget.experience['end_date'] ?? widget.experience['endDate'] ?? '') as String;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 40,
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  width: _hovered ? 14 : 10,
                  height: _hovered ? 14 : 10,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    border: Border.all(color: AppColors.deep, width: 3),
                  ),
                ),
                if (!widget.isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: MouseRegion(
              onEnter: (_) => setState(() => _hovered = true),
              onExit: (_) => setState(() => _hovered = false),
              child: GestureDetector(
                onTap: () => setState(() => _expanded = !_expanded),
                onTapDown: (_) => setState(() => _pressed = true),
                onTapUp: (_) => setState(() => _pressed = false),
                onTapCancel: () => setState(() => _pressed = false),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  margin: const EdgeInsets.only(bottom: 32),
                  padding: const EdgeInsets.all(28),
                  transform: _pressed
                      ? (Matrix4.identity()..translate(2.0, 2.0))
                      : Matrix4.identity(),
                  decoration: BoxDecoration(
                    color: AppColors.deep,
                    border: Border.all(
                      color: _hovered ? AppColors.accent : AppColors.border,
                      width: 2,
                    ),
                    boxShadow: [
                      if (!_pressed && _hovered)
                        BoxShadow(
                          color: AppColors.accent.withValues(alpha: 0.2),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              (widget.experience['position'] ?? '') as String,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ),
                          AnimatedRotation(
                            turns: _expanded ? 0.5 : 0,
                            duration: const Duration(milliseconds: 200),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: _expanded ? AppColors.accent : AppColors.surface,
                                border: Border.all(color: AppColors.border, width: 2),
                              ),
                              child: Icon(
                                Icons.keyboard_arrow_down,
                                color: _expanded ? AppColors.deep : AppColors.textMuted,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        (widget.experience['company'] ?? '') as String,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.accent,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 16,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textMuted),
                              const SizedBox(width: 6),
                              Text(
                                '$startDate — $endDate',
                                style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textMuted),
                              const SizedBox(width: 6),
                              Text(
                                (widget.experience['location'] ?? '') as String,
                                style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ],
                      ),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOut,
                        child: _expanded
                            ? Column(
                                children: [
                                  const SizedBox(height: 20),
                                  Container(width: double.infinity, height: 2, color: AppColors.border),
                                  const SizedBox(height: 20),
                                  ...highlights.map((h) {
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.only(top: 8),
                                            width: 6,
                                            height: 6,
                                            decoration: const BoxDecoration(
                                              color: AppColors.accent,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              h.toString(),
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: AppColors.textSecondary,
                                                height: 1.6,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                ],
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
