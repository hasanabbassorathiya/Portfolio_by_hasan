import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

class StoreButtons extends StatelessWidget {
  final String? iosUrl;
  final String? androidUrl;
  final String? webUrl;
  final bool compact;

  const StoreButtons({
    super.key,
    this.iosUrl,
    this.androidUrl,
    this.webUrl,
    this.compact = false,
  });

  bool get hasAnyStore => iosUrl != null || androidUrl != null || webUrl != null;

  @override
  Widget build(BuildContext context) {
    if (!hasAnyStore) return const SizedBox.shrink();

    final buttons = <Widget>[];
    if (androidUrl != null) {
      buttons.add(_StoreBadge(
        assetPath: 'assets/images/google_play_badge.svg',
        url: androidUrl!,
        compact: compact,
      ));
    }
    if (iosUrl != null) {
      buttons.add(_StoreBadge(
        assetPath: 'assets/images/app_store_badge.svg',
        url: iosUrl!,
        compact: compact,
      ));
    }
    if (webUrl != null) {
      buttons.add(_StoreBadge(
        assetPath: 'assets/images/google_play_badge.svg',
        url: webUrl!,
        compact: compact,
        fallbackLabel: 'Website',
      ));
    }

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: buttons,
    );
  }
}

class _StoreBadge extends StatefulWidget {
  final String assetPath;
  final String url;
  final bool compact;
  final String? fallbackLabel;

  const _StoreBadge({
    required this.assetPath,
    required this.url,
    this.compact = false,
    this.fallbackLabel,
  });

  @override
  State<_StoreBadge> createState() => _StoreBadgeState();
}

class _StoreBadgeState extends State<_StoreBadge> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final badgeHeight = widget.compact ? 36.0 : 44.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => launchUrl(Uri.parse(widget.url), mode: LaunchMode.externalApplication),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: _hovered ? (Matrix4.identity()..translate(0, -2)) : Matrix4.identity(),
          height: badgeHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              if (_hovered)
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.08),
                  blurRadius: 12,
                  spreadRadius: -2,
                ),
            ],
          ),
          child: widget.fallbackLabel != null
              ? _buildTextBadge()
              : ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SvgPicture.asset(
                    widget.assetPath,
                    height: badgeHeight,
                    fit: BoxFit.contain,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildTextBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: _hovered ? const Color(0xFF22C55E).withValues(alpha: 0.15) : const Color(0xFF1A1F35),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _hovered ? const Color(0xFF22C55E).withValues(alpha: 0.4) : const Color(0xFF334155),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.language_rounded,
            color: _hovered ? const Color(0xFF22C55E) : const Color(0xFF94A3B8),
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            widget.fallbackLabel!,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _hovered ? const Color(0xFF22C55E) : const Color(0xFFE2E8F0),
            ),
          ),
        ],
      ),
    );
  }
}
