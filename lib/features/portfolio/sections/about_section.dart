import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/database/portfolio_repository.dart';
import '../../../shared/widgets/scroll_reveal.dart';
import '../../../shared/widgets/bento_card.dart';
import '../../../shared/widgets/tech_chip.dart';
import '../../../shared/layouts/section_wrapper.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final isMobile = w < 600;
    final repo = PortfolioRepository();
    final about = (repo.profile['about'] as String?) ?? '';
    final rawStats = repo.profile['stats'];
    final stats = rawStats is List ? rawStats : [];
    final experience = repo.experience;
    final education = repo.education;
    final certs = repo.certifications;
    final skills = repo.skills;
    final languages = repo.languages;
    final skillCategories = repo.skillCategories;

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
                Text('ABOUT', style: AppTypography.label()),
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
                'Engineering excellence,\ndelivered.',
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
          const SizedBox(height: 24),

          ScrollReveal(
            direction: RevealDirection.up,
            delay: const Duration(milliseconds: 300),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 650),
              child: Text(
                about,
                style: AppTypography.body().copyWith(fontSize: 15, height: 1.7),
              ),
            ),
          ),
          const SizedBox(height: 64),

          ScrollReveal(
            direction: RevealDirection.up,
            delay: const Duration(milliseconds: 350),
            child: _buildStatsRow(stats, isMobile),
          ),
          const SizedBox(height: 48),

          if (experience.isNotEmpty) ...[
            ScrollReveal(
              direction: RevealDirection.up,
              delay: const Duration(milliseconds: 400),
              child: _buildSectionLabel('EXPERIENCE'),
            ),
            const SizedBox(height: 24),
            _buildExperienceTimeline(experience, isMobile),
            const SizedBox(height: 48),
          ],

          if (isMobile) ...[
            if (skills.isNotEmpty) ...[
              ScrollReveal(
                direction: RevealDirection.up,
                delay: const Duration(milliseconds: 450),
                child: _buildSkillsCard(skills, skillCategories),
              ),
              const SizedBox(height: 16),
            ],
            if (education.isNotEmpty || certs.isNotEmpty || languages.isNotEmpty)
              ScrollReveal(
                direction: RevealDirection.up,
                delay: const Duration(milliseconds: 500),
                child: _buildEducationCard(education, certs, languages),
              ),
          ] else
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (skills.isNotEmpty)
                    Expanded(
                      flex: 3,
                      child: ScrollReveal(
                        direction: RevealDirection.left,
                        delay: const Duration(milliseconds: 450),
                        child: _buildSkillsCard(skills, skillCategories),
                      ),
                    ),
                  if (skills.isNotEmpty) const SizedBox(width: 16),
                  if (education.isNotEmpty || certs.isNotEmpty || languages.isNotEmpty)
                    Expanded(
                      flex: 2,
                      child: ScrollReveal(
                        direction: RevealDirection.right,
                        delay: const Duration(milliseconds: 500),
                        child: _buildEducationCard(education, certs, languages),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(List stats, bool isMobile) {
    if (isMobile) {
      return Column(
        children: [
          Row(children: [
            for (int i = 0; i < 2 && i < stats.length; i++) ...[
              if (i > 0) const SizedBox(width: 12),
              Expanded(child: BentoCard(size: BentoSize.small, child: _buildStatBlock(stats[i]['value']?.toString() ?? '', stats[i]['label']?.toString() ?? ''))),
            ],
          ]),
          const SizedBox(height: 12),
          Row(children: [
            for (int i = 2; i < 4 && i < stats.length; i++) ...[
              if (i > 2) const SizedBox(width: 12),
              Expanded(child: BentoCard(size: BentoSize.small, child: _buildStatBlock(stats[i]['value']?.toString() ?? '', stats[i]['label']?.toString() ?? ''))),
            ],
          ]),
        ],
      );
    }
    return Row(
      children: [
        for (int i = 0; i < stats.length; i++) ...[
          if (i > 0) const SizedBox(width: 16),
          Expanded(child: BentoCard(size: BentoSize.small, child: _buildStatBlock(stats[i]['value']?.toString() ?? '', stats[i]['label']?.toString() ?? ''))),
        ],
      ],
    );
  }

  Widget _buildStatBlock(String value, String label) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(value, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: AppColors.accent, height: 1.0, letterSpacing: -2)),
        const SizedBox(height: 8),
        Text(label.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted, height: 1.3, letterSpacing: 1)),
      ]),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Row(children: [
      Container(width: 24, height: 2, color: AppColors.accent),
      const SizedBox(width: 12),
      Text(text, style: AppTypography.label()),
    ]);
  }

  Widget _buildExperienceTimeline(List experiences, bool isMobile) {
    if (isMobile) {
      return Column(
        children: [
          for (int i = 0; i < experiences.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            ScrollReveal(direction: RevealDirection.up, delay: Duration(milliseconds: 100 * i), child: _buildExperienceCard(experiences[i])),
          ],
        ],
      );
    }
    return StaggerReveal(
      direction: RevealDirection.up,
      staggerDelay: const Duration(milliseconds: 120),
      children: experiences.map<Widget>((e) => _buildExperienceCard(e)).toList(),
    );
  }

  Widget _buildExperienceCard(Map<String, dynamic> exp) {
    final highlights = exp['highlights'];
    final List<String> highlightList = highlights is List ? highlights.map((h) => h.toString()).toList() : [];

    return BentoCard(
      size: BentoSize.wide,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(width: 10, height: 10, margin: const EdgeInsets.only(top: 6), decoration: const BoxDecoration(color: AppColors.accent)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(exp['company']?.toString() ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                Text(exp['position']?.toString() ?? '', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.accent)),
                const SizedBox(height: 6),
                Row(children: [
                  const Icon(Icons.calendar_today_outlined, size: 12, color: AppColors.textMuted),
                  const SizedBox(width: 6),
                  Text('${exp['start_date'] ?? ''} – ${exp['end_date'] ?? ''}', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  const SizedBox(width: 16),
                  const Icon(Icons.location_on_outlined, size: 12, color: AppColors.textMuted),
                  const SizedBox(width: 6),
                  Text(exp['location']?.toString() ?? '', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                ]),
              ]),
            ),
          ]),
          if (highlightList.isNotEmpty) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(left: 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: highlightList.map((h) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('— ', style: TextStyle(color: AppColors.accent, fontSize: 13, fontWeight: FontWeight.w900)),
                    Expanded(child: Text(h, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5))),
                  ]),
                )).toList(),
              ),
            ),
          ],
        ]),
      ),
    );
  }

  Widget _buildSkillsCard(List skills, List<String> categories) {
    return BentoCard(
      size: BentoSize.tall,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('KEY SKILLS', style: AppTypography.label()),
            const SizedBox(height: 20),
            for (final cat in categories) ...[
              Text(cat.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.accent, letterSpacing: 1)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: skills.where((s) => s['category'] == cat).map((s) => TechChip(label: s['name']?.toString() ?? '', level: s['level']?.toString())).toList(),
              ),
              const SizedBox(height: 16),
            ],
          ]),
        ),
      ),
    );
  }

  Widget _buildEducationCard(List education, List certs, List languages) {
    return BentoCard(
      size: BentoSize.tall,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (education.isNotEmpty) ...[
              Text('EDUCATION', style: AppTypography.label()),
              const SizedBox(height: 20),
              for (final edu in education) ...[
                Text(edu['degree']?.toString() ?? '', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                Text(edu['institution']?.toString() ?? '', style: const TextStyle(fontSize: 13, color: AppColors.accent)),
                const SizedBox(height: 2),
                Text(edu['period']?.toString() ?? '', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                const SizedBox(height: 16),
              ],
            ],
            if (certs.isNotEmpty) ...[
              Text('CERTIFICATIONS', style: AppTypography.label()),
              const SizedBox(height: 20),
              for (final cert in certs) ...[
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Icon(Icons.verified_outlined, size: 16, color: AppColors.accent),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(cert['name']?.toString() ?? '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      Text(cert['issuer']?.toString() ?? '', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    ]),
                  ),
                ]),
                const SizedBox(height: 12),
              ],
            ],
            if (languages.isNotEmpty) ...[
              Text('LANGUAGES', style: AppTypography.label()),
              const SizedBox(height: 16),
              for (final lang in languages) ...[
                Row(children: [
                  const Icon(Icons.translate_outlined, size: 14, color: AppColors.textMuted),
                  const SizedBox(width: 10),
                  Text(lang['name']?.toString() ?? '', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: AppColors.border, width: 2)),
                    child: Text(lang['proficiency']?.toString() ?? '', style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
                  ),
                ]),
                const SizedBox(height: 8),
              ],
            ],
          ]),
        ),
      ),
    );
  }
}
