import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class ScrollProgressBar extends StatefulWidget {
  final ScrollController controller;

  const ScrollProgressBar({super.key, required this.controller});

  @override
  State<ScrollProgressBar> createState() => _ScrollProgressBarState();
}

class _ScrollProgressBarState extends State<ScrollProgressBar> {
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    final max = widget.controller.position.maxScrollExtent;
    if (max > 0) {
      setState(() => _progress = widget.controller.offset / max);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: 3,
          child: LinearProgressIndicator(
            value: _progress.clamp(0.0, 1.0),
            backgroundColor: AppColors.surface,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.only(right: 4),
                decoration: const BoxDecoration(
                  color: AppColors.accent,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
