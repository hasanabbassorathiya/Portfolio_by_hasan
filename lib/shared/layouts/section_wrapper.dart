import 'package:flutter/material.dart';
import '../../core/theme/app_spacing.dart';

class SectionWrapper extends StatelessWidget {
  final Widget child;
  final bool narrow;
  final double? verticalPadding;
  final String? id;

  const SectionWrapper({
    super.key,
    required this.child,
    this.narrow = false,
    this.verticalPadding,
    this.id,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 600;
    final vPad = verticalPadding ??
        (isMobile ? AppSpacing.sectionVerticalMobile : AppSpacing.sectionVertical);

    return Container(
      key: id != null ? Key(id!) : null,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 48,
        vertical: vPad,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
          child: child,
        ),
      ),
    );
  }
}
