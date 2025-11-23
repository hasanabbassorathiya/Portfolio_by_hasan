import 'package:flutter/material.dart';
import 'package:portfolio/shared/constants/design_tokens.dart';

/// Application color constants
/// Extracted from Figma design and organized for easy access
class AppColors {
  AppColors._();

  // Primary colors
  static const Color primary = DesignTokens.primaryDark;
  static const Color primaryColor = DesignTokens.primaryDark;
  static const Color bgColor = DesignTokens.backgroundWhite;
  static const Color background = DesignTokens.backgroundWhite;
  static const Color backgroundDark = DesignTokens.backgroundDark;

  // Text colors
  static const Color textPrimary = DesignTokens.primaryDark;
  static const Color textSecondary = DesignTokens.textSecondary;
  static const Color textWhite = DesignTokens.backgroundWhite;
  static const Color textDark = Color(0xFF191917);

  // Gradient colors
  static const Color gradientOrange = DesignTokens.gradientOrange;
  static const Color gradientRed = DesignTokens.gradientRed;
  static const Color gradientPurple = DesignTokens.gradientPurple;

  // Gradients
  static const LinearGradient primaryGradient = DesignTokens.primaryGradient;
  static const LinearGradient secondaryGradient =
      DesignTokens.secondaryGradient;

  // Border colors
  static const Color borderLight = DesignTokens.borderLight;
  static const Color borderDark = DesignTokens.borderDark;

  // Shadow colors
  static const Color shadowOrange = DesignTokens.shadowOrange;
  static const Color shadowBlack = DesignTokens.shadowBlack;

  // Opacity variants
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }

  // Common opacity values
  static const double opacity20 = 0.2;
  static const double opacity30 = 0.3;
  static const double opacity50 = 0.5;
  static const double opacity80 = 0.8;
  static const double opacity100 = 1.0;
}
