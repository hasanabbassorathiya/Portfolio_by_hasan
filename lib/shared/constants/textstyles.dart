import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:portfolio/shared/constants/colors.dart';
import 'package:portfolio/shared/constants/design_tokens.dart';

/// Application text styles
/// Extracted from Figma design with responsive scaling support
class AppStyles {
  AppStyles._();

  // ==================== Display Styles ====================
  /// Hero text style - Large display text (e.g., "My name is Hasan abbas Sorathiya...")
  static TextStyle hero({Color? color, BuildContext? context}) {
    final fontSize =
        context != null
            ? DesignTokens.responsiveFontSize(context, DesignTokens.fontSize102)
            : DesignTokens.fontSize102;
    return GoogleFonts.poppins(
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
      height: DesignTokens.lineHeight0_686,
      color: color ?? AppColors.textDark,
      letterSpacing: 0,
    );
  }

  /// Display large - Section titles (e.g., "Contact", "Service")
  static TextStyle displayLarge({Color? color, BuildContext? context}) {
    final fontSize =
        context != null
            ? DesignTokens.responsiveFontSize(context, DesignTokens.fontSize48)
            : DesignTokens.fontSize48;
    return GoogleFonts.ibmPlexSans(
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      height: DesignTokens.lineHeight1_166,
      color: color ?? AppColors.primary,
      letterSpacing: 0,
    );
  }

  // ==================== Heading Styles ====================
  /// Heading style - Main section headings (e.g., "Reach out me", "My Specialties")
  static TextStyle heading({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    BuildContext? context,
  }) {
    final size = fontSize ?? DesignTokens.fontSize40;
    final finalSize =
        context != null ? DesignTokens.responsiveFontSize(context, size) : size;
    return GoogleFonts.ibmPlexSans(
      fontSize: finalSize,
      fontWeight: fontWeight ?? FontWeight.w700,
      height: DesignTokens.lineHeight1_2,
      color: color ?? AppColors.primary,
      letterSpacing: 0,
    );
  }

  /// Subheading style - Section labels (e.g., "Contact", "Service", "Work")
  static TextStyle subheading({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    BuildContext? context,
  }) {
    final size = fontSize ?? DesignTokens.fontSize18;
    final finalSize =
        context != null ? DesignTokens.responsiveFontSize(context, size) : size;
    return GoogleFonts.ibmPlexSans(
      fontSize: finalSize,
      fontWeight: fontWeight ?? FontWeight.w600,
      height: DesignTokens.lineHeight1_33,
      color: color ?? AppColors.primary,
      letterSpacing: 0,
    );
  }

  /// Title large - Card titles and important text
  static TextStyle titleLarge({Color? color, BuildContext? context}) {
    final fontSize =
        context != null
            ? DesignTokens.responsiveFontSize(context, DesignTokens.fontSize32)
            : DesignTokens.fontSize32;
    return GoogleFonts.ibmPlexSans(
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      height: DesignTokens.lineHeight1_5,
      color: color ?? AppColors.primary,
      letterSpacing: 0,
    );
  }

  /// Title medium - Secondary titles
  static TextStyle titleMedium({Color? color, BuildContext? context}) {
    final fontSize =
        context != null
            ? DesignTokens.responsiveFontSize(context, DesignTokens.fontSize24)
            : DesignTokens.fontSize24;
    return GoogleFonts.ibmPlexSans(
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      height: DesignTokens.lineHeight1_25,
      color: color ?? AppColors.primary,
      letterSpacing: 0,
    );
  }

  /// Title small - Small titles
  static TextStyle titleSmall({Color? color, BuildContext? context}) {
    final fontSize =
        context != null
            ? DesignTokens.responsiveFontSize(context, DesignTokens.fontSize20)
            : DesignTokens.fontSize20;
    return GoogleFonts.ibmPlexSans(
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      height: DesignTokens.lineHeight1_6,
      color: color ?? AppColors.primary,
      letterSpacing: 0,
    );
  }

  // ==================== Body Styles ====================
  /// Body text style - Standard body text
  static TextStyle body({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    BuildContext? context,
  }) {
    final size = fontSize ?? DesignTokens.fontSize16;
    final finalSize =
        context != null ? DesignTokens.responsiveFontSize(context, size) : size;
    return GoogleFonts.ibmPlexSans(
      fontSize: finalSize,
      fontWeight: fontWeight ?? FontWeight.w500,
      height: DesignTokens.lineHeight1_5,
      color: color ?? AppColors.primary,
      letterSpacing: DesignTokens.letterSpacingMinus3,
    );
  }

  /// Body large - Larger body text
  static TextStyle bodyLarge({Color? color, BuildContext? context}) {
    final fontSize =
        context != null
            ? DesignTokens.responsiveFontSize(context, DesignTokens.fontSize18)
            : DesignTokens.fontSize18;
    return GoogleFonts.jost(
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
      height: DesignTokens.lineHeight1_555,
      color: color ?? AppColors.primary,
      letterSpacing: 0,
    );
  }

  /// Body medium - Standard body text
  static TextStyle bodyMedium({Color? color, BuildContext? context}) {
    final fontSize =
        context != null
            ? DesignTokens.responsiveFontSize(context, DesignTokens.fontSize16)
            : DesignTokens.fontSize16;
    return GoogleFonts.ibmPlexSans(
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
      height: DesignTokens.lineHeight1_4,
      color: color ?? AppColors.primary,
      letterSpacing: DesignTokens.letterSpacingMinus3,
    );
  }

  /// Body small - Smaller body text
  static TextStyle bodySmall({Color? color, BuildContext? context}) {
    final fontSize =
        context != null
            ? DesignTokens.responsiveFontSize(context, DesignTokens.fontSize11)
            : DesignTokens.fontSize11;
    return GoogleFonts.ibmPlexSans(
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
      height: DesignTokens.lineHeight1_375,
      color: color ?? Colors.grey,
      letterSpacing: 0,
    );
  }

  // ==================== Special Styles ====================
  /// Large body text - For phone numbers, emails (e.g., "+971 58 960 2320")
  static TextStyle largeBody({
    Color? color,
    double? fontSize,
    BuildContext? context,
  }) {
    final size = fontSize ?? DesignTokens.fontSize26;
    final finalSize =
        context != null ? DesignTokens.responsiveFontSize(context, size) : size;
    return GoogleFonts.ibmPlexSans(
      fontSize: finalSize,
      fontWeight: FontWeight.w700,
      height: DesignTokens.lineHeight1_538,
      color: color ?? AppColors.primary,
      letterSpacing: 0,
    );
  }

  /// Regular text - Standard regular weight text
  static TextStyle regular({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    BuildContext? context,
  }) {
    final size = fontSize ?? DesignTokens.fontSize16;
    final finalSize =
        context != null ? DesignTokens.responsiveFontSize(context, size) : size;
    return GoogleFonts.ibmPlexSans(
      fontSize: finalSize,
      fontWeight: fontWeight ?? FontWeight.w400,
      height: DesignTokens.lineHeight1_5,
      color: color ?? AppColors.primary,
      letterSpacing: DesignTokens.letterSpacingMinus3,
    );
  }

  /// Button text style
  static TextStyle button({
    Color? color,
    double? fontSize,
    BuildContext? context,
  }) {
    final size = fontSize ?? DesignTokens.fontSize18;
    final finalSize =
        context != null ? DesignTokens.responsiveFontSize(context, size) : size;
    return GoogleFonts.ibmPlexSans(
      fontSize: finalSize,
      fontWeight: FontWeight.w500,
      height: DesignTokens.lineHeight1_33,
      color: color ?? AppColors.textWhite,
      letterSpacing: 0,
    );
  }

  /// Menu item text style
  static TextStyle menuItem({
    Color? color,
    bool isActive = false,
    BuildContext? context,
  }) {
    final fontSize =
        context != null
            ? DesignTokens.responsiveFontSize(context, DesignTokens.fontSize20)
            : DesignTokens.fontSize20;
    return GoogleFonts.ibmPlexSans(
      fontSize: fontSize,
      fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
      height: DesignTokens.lineHeight1_5,
      color: color ?? AppColors.textWhite,
      letterSpacing: 0,
    );
  }

  /// Logo text style
  static TextStyle logo({Color? color, BuildContext? context}) {
    final fontSize =
        context != null
            ? DesignTokens.responsiveFontSize(context, DesignTokens.fontSize30)
            : DesignTokens.fontSize30;
    return GoogleFonts.ibmPlexSerif(
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      height: DesignTokens.lineHeight1_3,
      color: color ?? AppColors.textWhite,
      letterSpacing: 0,
    );
  }

  /// Name text style - For personal name display
  static TextStyle name({Color? color, BuildContext? context}) {
    final fontSize =
        context != null
            ? DesignTokens.responsiveFontSize(context, DesignTokens.fontSize36)
            : DesignTokens.fontSize36;
    return GoogleFonts.ibmPlexSans(
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      height: DesignTokens.lineHeight1_111,
      color: color ?? AppColors.textWhite,
      letterSpacing: DesignTokens.letterSpacingMinus5,
    );
  }

  /// Subtitle text style - For role/title display
  static TextStyle subtitle({Color? color, BuildContext? context}) {
    final fontSize =
        context != null
            ? DesignTokens.responsiveFontSize(context, DesignTokens.fontSize32)
            : DesignTokens.fontSize32;
    return GoogleFonts.ibmPlexSans(
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
      height: DesignTokens.lineHeight1_0,
      color: color ?? AppColors.primary,
      letterSpacing: DesignTokens.letterSpacingMinus3,
    );
  }

  /// Quote text style - For testimonial quotes
  static TextStyle quote({Color? color, BuildContext? context}) {
    final fontSize =
        context != null
            ? DesignTokens.responsiveFontSize(context, DesignTokens.fontSize32)
            : DesignTokens.fontSize32;
    return GoogleFonts.ibmPlexSans(
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      height: DesignTokens.lineHeight1_25,
      color: color ?? AppColors.textWhite,
      letterSpacing: 0,
    );
  }

  /// Testimonial author style
  static TextStyle testimonialAuthor({Color? color, BuildContext? context}) {
    final fontSize =
        context != null
            ? DesignTokens.responsiveFontSize(context, DesignTokens.fontSize24)
            : DesignTokens.fontSize24;
    return GoogleFonts.ibmPlexSans(
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      height: DesignTokens.lineHeight1_299,
      color: color ?? AppColors.textWhite,
      letterSpacing: 0,
    );
  }

  /// Testimonial role style
  static TextStyle testimonialRole({Color? color, BuildContext? context}) {
    final fontSize =
        context != null
            ? DesignTokens.responsiveFontSize(context, DesignTokens.fontSize16)
            : DesignTokens.fontSize16;
    return GoogleFonts.ibmPlexSans(
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
      height: DesignTokens.lineHeight1_299,
      color: color ?? AppColors.textWhite,
      letterSpacing: DesignTokens.letterSpacingMinus1,
    );
  }
}
