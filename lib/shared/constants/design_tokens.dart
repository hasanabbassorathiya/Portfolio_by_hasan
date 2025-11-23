import 'package:flutter/material.dart';

/// Design tokens extracted from Figma design
/// Provides centralized design system values for colors, typography, spacing, and breakpoints
class DesignTokens {
  DesignTokens._();

  // ==================== Colors ====================
  /// Primary dark color used throughout the design
  static const Color primaryDark = Color(0xFF141313);

  /// Background white color
  static const Color backgroundWhite = Color(0xFFFFFFFF);

  /// Dark background color
  static const Color backgroundDark = Color(0xFF171717);

  /// Text color with opacity
  static const Color textSecondary = Color(0xCC141313); // 80% opacity

  /// Gradient colors
  static const Color gradientOrange = Color(
    0xFFFFB147,
  ); // rgba(255, 177, 71, 1)
  static const Color gradientRed = Color(0xFFFF6C63); // rgba(255, 108, 99, 1)
  static const Color gradientPurple = Color(
    0xFFB86ADF,
  ); // rgba(184, 106, 223, 1)

  /// Gradient for buttons and accents
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment(-0.87, 0),
    end: Alignment(0.87, 0),
    colors: [gradientOrange, gradientRed, gradientPurple],
    stops: [0.06, 0.51, 0.92],
  );

  /// Gradient for testimonials and special sections
  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment(0.86, 0),
    end: Alignment(-0.86, 0),
    colors: [gradientOrange, gradientRed, gradientPurple],
    stops: [0.32, 0.64, 0.93],
  );

  /// Border colors
  static const Color borderLight = Color(0x1AFFFFFF); // 10% opacity white
  static const Color borderDark = Color(0x1A141313); // 10% opacity dark

  /// Shadow colors
  static const Color shadowOrange = Color(0xFFE77762);
  static const Color shadowBlack = Color(0x40000000); // 25% opacity

  // ==================== Typography ====================
  /// Font families
  static const String fontPrimary = 'IBM Plex Sans';
  static const String fontSecondary = 'Poppins';
  static const String fontTertiary = 'Jost';
  static const String fontSerif = 'IBM Plex Serif';

  /// Font sizes (in logical pixels)
  static const double fontSize11 = 11.0;
  static const double fontSize12 = 12.0;
  static const double fontSize14 = 14.0;
  static const double fontSize16 = 16.0;
  static const double fontSize18 = 18.0;
  static const double fontSize20 = 20.0;
  static const double fontSize24 = 24.0;
  static const double fontSize26 = 26.0;
  static const double fontSize30 = 30.0;
  static const double fontSize32 = 32.0;
  static const double fontSize36 = 36.0;
  static const double fontSize40 = 40.0;
  static const double fontSize48 = 48.0;
  static const double fontSize57 = 57.0;
  static const double fontSize102 = 102.0;

  /// Line heights
  static const double lineHeight1_2 = 1.2;
  static const double lineHeight1_25 = 1.25;
  static const double lineHeight1_3 = 1.3;
  static const double lineHeight1_33 = 1.3333333333333333;
  static const double lineHeight1_375 = 1.375;
  static const double lineHeight1_4 = 1.4;
  static const double lineHeight1_5 = 1.5;
  static const double lineHeight1_538 = 1.5384615384615385;
  static const double lineHeight1_555 = 1.5555555555555556;
  static const double lineHeight1_0 = 1.0;
  static const double lineHeight1_111 = 1.1111111111111112;
  static const double lineHeight1_166 = 1.1666666666666667;
  static const double lineHeight1_299 = 1.2999999523162842;
  static const double lineHeight1_6 = 1.6;
  static const double lineHeight1_75 = 1.75;
  static const double lineHeight0_686 = 0.6862745098039216;

  /// Letter spacing
  static const double letterSpacingMinus1 = -0.01;
  static const double letterSpacingMinus3 = -0.03;
  static const double letterSpacingMinus5 = -0.05;

  // ==================== Spacing ====================
  /// Base spacing unit (4px)
  static const double spaceUnit = 4.0;

  /// Spacing values
  static const double space4 = 4.0;
  static const double space6 = 6.0;
  static const double space8 = 8.0;
  static const double space10 = 10.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space18 = 18.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space30 = 30.0;
  static const double space32 = 32.0;
  static const double space40 = 40.0;
  static const double space48 = 48.0;
  static const double space56 = 56.0;
  static const double space60 = 60.0;
  static const double space64 = 64.0;
  static const double space85 = 85.0;
  static const double space100 = 100.0;
  static const double space115 = 115.0;
  static const double space140 = 140.0;
  static const double space148 = 148.0;
  static const double space212 = 212.0;
  static const double space244 = 244.0;
  static const double space285 = 285.0; // Sidebar width

  /// Padding values
  static const double padding18 = 18.0;
  static const double padding40 = 40.0;
  static const double padding48 = 48.0;

  /// Border radius
  static const double borderRadius0 = 0.0;
  static const double borderRadius4 = 4.0;
  static const double borderRadius8 = 8.0;
  static const double borderRadius12 = 12.0;
  static const double borderRadius16 = 16.0;

  // ==================== Layout Dimensions ====================
  /// Sidebar width (desktop)
  static const double sidebarWidth = 285.0;

  /// Content area padding
  static const double contentPadding = 115.0;

  /// Button dimensions
  static const double buttonHeight = 56.0;
  static const double buttonPaddingHorizontal = 40.0;
  static const double buttonPaddingVertical = 18.0;

  /// Icon sizes
  static const double iconSize16 = 16.0;
  static const double iconSize18 = 18.0;
  static const double iconSize20 = 20.0;
  static const double iconSize24 = 24.0;
  static const double iconSize32 = 32.0;
  static const double iconSize40 = 40.0;
  static const double iconSize60 = 60.0;
  static const double iconSize64 = 64.0;

  /// Image dimensions
  static const double avatarSize = 430.0;
  static const double workImageWidth = 315.0;
  static const double workImageHeight = 248.0;
  static const double blogImageWidth = 315.0;
  static const double blogImageHeight = 260.0;

  // ==================== Responsive Breakpoints ====================
  /// Breakpoints for responsive design
  static const double breakpointMobile = 360.0; // Small phones
  static const double breakpointMobileLarge = 414.0; // Large phones
  static const double breakpointPhablet = 600.0; // Phablets
  static const double breakpointTablet = 768.0; // Tablets
  static const double breakpointTabletLarge = 1024.0; // Large tablets
  static const double breakpointDesktop = 1280.0; // Desktop
  static const double breakpointDesktopLarge = 1920.0; // Large desktop

  /// Get responsive value based on screen width
  static T responsive<T>({
    required BuildContext context,
    required T mobile,
    T? mobileLarge,
    T? phablet,
    T? tablet,
    T? tabletLarge,
    T? desktop,
    T? desktopLarge,
  }) {
    final width = MediaQuery.of(context).size.width;

    if (width >= breakpointDesktopLarge && desktopLarge != null) {
      return desktopLarge;
    } else if (width >= breakpointDesktop && desktop != null) {
      return desktop;
    } else if (width >= breakpointTabletLarge && tabletLarge != null) {
      return tabletLarge;
    } else if (width >= breakpointTablet && tablet != null) {
      return tablet;
    } else if (width >= breakpointPhablet && phablet != null) {
      return phablet;
    } else if (width >= breakpointMobileLarge && mobileLarge != null) {
      return mobileLarge;
    }
    return mobile;
  }

  /// Check if current screen is mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < breakpointTablet;
  }

  /// Check if current screen is tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= breakpointTablet && width < breakpointDesktop;
  }

  /// Check if current screen is desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= breakpointDesktop;
  }

  /// Get responsive padding
  static EdgeInsets responsivePadding(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: responsive<double>(
        context: context,
        mobile: space16,
        mobileLarge: space24,
        phablet: space48,
        tablet: space85,
        tabletLarge: space100,
        desktop: space115,
        desktopLarge: space115,
      ),
      vertical: responsive<double>(
        context: context,
        mobile: space16,
        mobileLarge: space24,
        phablet: space32,
        tablet: space48,
        tabletLarge: space56,
        desktop: space64,
        desktopLarge: space64,
      ),
    );
  }

  /// Get responsive font size
  static double responsiveFontSize(BuildContext context, double baseSize) {
    final width = MediaQuery.of(context).size.width;
    if (width < breakpointMobile) {
      return baseSize * 0.75; // 25% smaller on very small screens
    } else if (width < breakpointPhablet) {
      return baseSize * 0.875; // 12.5% smaller on mobile
    } else if (width < breakpointTablet) {
      return baseSize * 0.9375; // 6.25% smaller on phablet
    }
    return baseSize; // Full size on tablet and above
  }

  /// Get responsive sidebar width
  static double responsiveSidebarWidth(BuildContext context) {
    if (isMobile(context)) {
      return 0; // No sidebar on mobile
    } else if (isTablet(context)) {
      return space140; // Smaller sidebar on tablet
    }
    return sidebarWidth; // Full sidebar on desktop
  }

  /// Get responsive content padding
  static double responsiveContentPadding(BuildContext context) {
    return responsive<double>(
      context: context,
      mobile: space16,
      mobileLarge: space24,
      phablet: space48,
      tablet: space85,
      tabletLarge: space100,
      desktop: space115,
      desktopLarge: space115,
    );
  }
}
