import 'package:flutter/material.dart';

enum Breakpoint { mobile, tablet, desktop }

class ResponsiveBuilder extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  static Breakpoint breakpoint(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w < 600) return Breakpoint.mobile;
    if (w < 1024) return Breakpoint.tablet;
    return Breakpoint.desktop;
  }

  static bool isMobile(BuildContext context) => MediaQuery.sizeOf(context).width < 600;
  static bool isTablet(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return w >= 600 && w < 1024;
  }
  static bool isDesktop(BuildContext context) => MediaQuery.sizeOf(context).width >= 1024;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) return mobile;
        if (constraints.maxWidth < 1024) return tablet ?? desktop;
        return desktop;
      },
    );
  }
}
