import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/scroll_reveal.dart';
import '../../../shared/widgets/magnetic_cursor.dart';
import '../../../shared/widgets/cal_com_embed.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../../shared/layouts/section_wrapper.dart';
import '../../../core/config/app_config.dart';
import '../../../core/services/contact_service.dart';

class ContactSection extends StatefulWidget {
  const ContactSection({super.key});

  @override
  State<ContactSection> createState() => _ContactSectionState();
}

class _ContactSectionState extends State<ContactSection> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  bool _sending = false;
  bool _sent = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _submit() async {
    setState(() => _sending = true);

    final success = await ContactService.submit(
      name: _nameController.text,
      email: _emailController.text,
      message: _messageController.text,
    );

    setState(() {
      _sending = false;
      _sent = success;
    });

    if (success) {
      _nameController.clear();
      _emailController.clear();
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final isMobile = w < 600;

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
                Text('CONTACT', style: AppTypography.label()),
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
                'Let\'s build together.',
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
              'Have a project in mind? I\'d love to hear about it.',
              style: AppTypography.body(),
            ),
          ),
          const SizedBox(height: 64),
          if (isMobile) ...[
            ScrollReveal(
              direction: RevealDirection.up,
              delay: const Duration(milliseconds: 400),
              child: _buildForm(isMobile),
            ),
            const SizedBox(height: 32),
            _buildCalCom(),
          ] else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: ScrollReveal(
                    direction: RevealDirection.left,
                    delay: const Duration(milliseconds: 400),
                    child: _buildForm(isMobile),
                  ),
                ),
                const SizedBox(width: 32),
                Expanded(
                  flex: 2,
                  child: _buildCalCom(),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildForm(bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(28),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_sent) ...[
            const SizedBox(height: 40),
            Center(
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(color: AppColors.accent),
                    child: const Icon(Icons.check_circle, color: AppColors.deep, size: 32),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'MESSAGE SENT!',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'I will get back to you within 24 hours.',
                    style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ] else ...[
            _buildField('NAME', _nameController),
            const SizedBox(height: 20),
            _buildField('EMAIL', _emailController),
            const SizedBox(height: 20),
            _buildField('MESSAGE', _messageController, maxLines: 5),
            const SizedBox(height: 28),
            MagneticCursor(
              strength: 0.1,
              child: GradientButton(
                label: _sending ? 'Sending...' : 'Send Message',
                onPressed: _sending ? () {} : _submit,
                icon: Icons.send,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textMuted,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
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
      ],
    );
  }

  Widget _buildCalCom() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'OR BOOK A CALL',
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.accent,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border, width: 2),
          ),
          child: CalComEmbed(
            calLink: AppConfig.calComUsername,
          ),
        ),
      ],
    );
  }
}
