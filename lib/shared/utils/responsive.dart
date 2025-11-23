import 'package:flutter/material.dart';
import 'package:portfolio/shared/constants/design_tokens.dart';

/// Responsive utility functions
/// Provides helper methods for creating responsive layouts
class Responsive {
  Responsive._();

  /// Get responsive value based on screen width
  static T value<T>({
    required BuildContext context,
    required T mobile,
    T? mobileLarge,
    T? phablet,
    T? tablet,
    T? tabletLarge,
    T? desktop,
    T? desktopLarge,
  }) {
    return DesignTokens.responsive<T>(
      context: context,
      mobile: mobile,
      mobileLarge: mobileLarge,
      phablet: phablet,
      tablet: tablet,
      tabletLarge: tabletLarge,
      desktop: desktop,
      desktopLarge: desktopLarge,
    );
  }

  /// Get responsive padding
  static EdgeInsets padding(BuildContext context) {
    return DesignTokens.responsivePadding(context);
  }

  /// Get responsive horizontal padding
  static double horizontalPadding(BuildContext context) {
    return DesignTokens.responsiveContentPadding(context);
  }

  /// Get responsive font size
  static double fontSize(BuildContext context, double baseSize) {
    return DesignTokens.responsiveFontSize(context, baseSize);
  }

  /// Get responsive sidebar width
  static double sidebarWidth(BuildContext context) {
    return DesignTokens.responsiveSidebarWidth(context);
  }

  /// Check if mobile
  static bool isMobile(BuildContext context) {
    return DesignTokens.isMobile(context);
  }

  /// Check if tablet
  static bool isTablet(BuildContext context) {
    return DesignTokens.isTablet(context);
  }

  /// Check if desktop
  static bool isDesktop(BuildContext context) {
    return DesignTokens.isDesktop(context);
  }

  /// Get screen width
  static double width(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Get screen height
  static double height(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Get responsive column count for grids
  static int gridColumnCount(BuildContext context) {
    return value<int>(
      context: context,
      mobile: 1,
      mobileLarge: 1,
      phablet: 2,
      tablet: 2,
      tabletLarge: 3,
      desktop: 3,
      desktopLarge: 4,
    );
  }

  /// Get responsive gap for grids
  static double gridGap(BuildContext context) {
    return value<double>(
      context: context,
      mobile: DesignTokens.space16,
      mobileLarge: DesignTokens.space20,
      phablet: DesignTokens.space24,
      tablet: DesignTokens.space30,
      tabletLarge: DesignTokens.space30,
      desktop: DesignTokens.space30,
      desktopLarge: DesignTokens.space30,
    );
  }

  /// Get responsive max content width
  static double maxContentWidth(BuildContext context) {
    return value<double>(
      context: context,
      mobile: double.infinity,
      mobileLarge: double.infinity,
      phablet: 600,
      tablet: 768,
      tabletLarge: 1024,
      desktop: 1280,
      desktopLarge: 1920,
    );
  }

  /// Get responsive spacing multiplier
  static double spacingMultiplier(BuildContext context) {
    return value<double>(
      context: context,
      mobile: 0.75,
      mobileLarge: 0.875,
      phablet: 0.9375,
      tablet: 1.0,
      tabletLarge: 1.0,
      desktop: 1.0,
      desktopLarge: 1.0,
    );
  }
}

/// Responsive builder widget
/// Builds different widgets based on screen size
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.mobileLarge,
    this.phablet,
    this.tablet,
    this.tabletLarge,
    this.desktop,
    this.desktopLarge,
  });

  final Widget mobile;
  final Widget? mobileLarge;
  final Widget? phablet;
  final Widget? tablet;
  final Widget? tabletLarge;
  final Widget? desktop;
  final Widget? desktopLarge;

  @override
  Widget build(BuildContext context) {
    return Responsive.value<Widget>(
      context: context,
      mobile: mobile,
      mobileLarge: mobileLarge,
      phablet: phablet,
      tablet: tablet,
      tabletLarge: tabletLarge,
      desktop: desktop,
      desktopLarge: desktopLarge,
    );
  }
}
