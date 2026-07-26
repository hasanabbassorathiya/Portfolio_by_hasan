import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class MarqueeText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final double speed;
  final double spacing;
  final Color? backgroundColor;
  final Color? textColor;

  const MarqueeText({
    super.key,
    required this.text,
    this.style,
    this.speed = 50,
    this.spacing = 80,
    this.backgroundColor,
    this.textColor,
  });

  @override
  State<MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<MarqueeText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final ScrollController _scrollCtrl = ScrollController();
  bool _paused = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _startScroll());
    _controller.addListener(_onTick);
  }

  void _startScroll() {
    if (!_scrollCtrl.hasClients) return;
    final max = _scrollCtrl.position.maxScrollExtent;
    if (max <= 0) return;
    _controller.duration = Duration(milliseconds: (max / widget.speed * 1000).toInt());
    _controller.repeat();
  }

  void _onTick() {
    if (!_scrollCtrl.hasClients || _paused) return;
    final max = _scrollCtrl.position.maxScrollExtent;
    if (max <= 0) return;
    _scrollCtrl.jumpTo(_controller.value * max);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTick);
    _controller.dispose();
    if (_scrollCtrl.hasClients) _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.backgroundColor ?? AppColors.accent.withValues(alpha: 0.06);
    final txtColor = widget.textColor ?? AppColors.textMuted;
    final txtStyle = widget.style ?? TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 6,
      color: txtColor,
    );

    final repeatedText = List.filled(8, widget.text).join(' ${'·'.padLeft(1)} ');

    return MouseRegion(
      onEnter: (_) => setState(() => _paused = true),
      onExit: (_) => setState(() => _paused = false),
      child: Container(
        height: 56,
        width: double.infinity,
        color: bgColor,
        child: SingleChildScrollView(
          controller: _scrollCtrl,
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(repeatedText, style: txtStyle),
          ),
        ),
      ),
    );
  }
}
