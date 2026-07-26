import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';

class SocialIconButton extends StatefulWidget {
  final IconData icon;
  final String url;
  final String tooltip;

  const SocialIconButton({
    super.key,
    required this.icon,
    required this.url,
    required this.tooltip,
  });

  @override
  State<SocialIconButton> createState() => _SocialIconButtonState();
}

class _SocialIconButtonState extends State<SocialIconButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Tooltip(
        message: widget.tooltip,
        child: GestureDetector(
          onTap: () => launchUrl(Uri.parse(widget.url), mode: LaunchMode.externalApplication),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _hovered ? AppColors.accentSubtle : AppColors.glassFill,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _hovered ? AppColors.accent.withValues(alpha: 0.3) : AppColors.glassBorder,
                width: 1,
              ),
            ),
            child: Icon(
              widget.icon,
              size: 20,
              color: _hovered ? AppColors.accent : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
