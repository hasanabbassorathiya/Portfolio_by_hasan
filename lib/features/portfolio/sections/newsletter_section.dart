import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/scroll_reveal.dart';
import '../../../shared/widgets/magnetic_cursor.dart';
import '../../../shared/layouts/section_wrapper.dart';
import '../../../core/services/newsletter_service.dart';

class NewsletterSection extends StatefulWidget {
  const NewsletterSection({super.key});

  @override
  State<NewsletterSection> createState() => _NewsletterSectionState();
}

class _NewsletterSectionState extends State<NewsletterSection> {
  final _emailController = TextEditingController();
  bool _subscribed = false;
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _subscribe() async {
    if (_emailController.text.isEmpty) return;
    setState(() => _loading = true);

    final success = await NewsletterService.subscribe(_emailController.text);

    setState(() {
      _loading = false;
      _subscribed = success;
    });

    if (success) _emailController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final isMobile = w < 600;

    return SectionWrapper(
      child: ScrollReveal(
        direction: RevealDirection.up,
        child: Container(
          padding: const EdgeInsets.all(40),
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
          child: isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildContent(),
                    const SizedBox(height: 24),
                    _buildInput(),
                  ],
                )
              : Row(
                  children: [
                    Expanded(child: _buildContent()),
                    const SizedBox(width: 40),
                    _buildInput(),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: const BoxDecoration(color: AppColors.accent),
          child: const Text(
            'STAY UPDATED',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.deep,
              letterSpacing: 2,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Get insights on Flutter architecture, AI integration, and engineering leadership.',
          style: TextStyle(
            fontSize: 15,
            color: AppColors.textSecondary,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildInput() {
    if (_subscribed) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(color: AppColors.accent),
            child: const Icon(Icons.check, color: AppColors.deep, size: 18),
          ),
          const SizedBox(width: 12),
          Text(
            'SUBSCRIBED!',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.accent,
              letterSpacing: 1,
            ),
          ),
        ],
      );
    }

    return SizedBox(
      width: 360,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _emailController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'your@email.com',
                hintStyle: TextStyle(color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.deep,
                border: const OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.border, width: 2),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.border, width: 2),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.accent, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
          const SizedBox(width: 12),
          MagneticCursor(
            strength: 0.1,
            child: GestureDetector(
              onTap: _loading ? null : _subscribe,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                decoration: const BoxDecoration(color: AppColors.accent),
                child: _loading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.deep,
                        ),
                      )
                    : const Text(
                        'SUBSCRIBE',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.deep,
                          letterSpacing: 1,
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
