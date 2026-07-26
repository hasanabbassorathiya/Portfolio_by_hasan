import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/layouts/section_wrapper.dart';
import '../../../shared/widgets/social_icon_button.dart';
import '../../../shared/widgets/decorative_effects.dart';
import '../../../core/config/app_config.dart';
import '../../../data/profile_data.dart';

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border, width: 2)),
      ),
      child: SectionWrapper(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SocialIconButton(
                  icon: Icons.link,
                  url: AppConfig.linkedInUrl,
                  tooltip: 'LinkedIn',
                ),
                const SizedBox(width: 12),
                SocialIconButton(
                  icon: Icons.email_outlined,
                  url: 'mailto:${AppProfileData.email}',
                  tooltip: 'Email',
                ),
                const SizedBox(width: 12),
                SocialIconButton(
                  icon: Icons.coffee,
                  url: AppConfig.buyMeACoffeeUrl,
                  tooltip: 'Buy Me a Coffee',
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              AppProfileData.name.toUpperCase(),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppProfileData.title.toUpperCase(),
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textMuted,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 32),
            GlowLine(width: 60, height: 2),
            const SizedBox(height: 32),
            Text(
              '© ${DateTime.now().year} ${AppProfileData.name.toUpperCase()}. ALL RIGHTS RESERVED.',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textMuted.withValues(alpha: 0.6),
                letterSpacing: 1,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () {
                Scrollable.ensureVisible(
                  context,
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutCubic,
                );
              },
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: Border.all(color: AppColors.border, width: 2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.keyboard_arrow_up, size: 16, color: AppColors.textMuted),
                      const SizedBox(width: 6),
                      Text(
                        'BACK TO TOP',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMuted,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
