import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';

import 'package:portfolio/shared/constants/colors.dart';
import 'package:portfolio/shared/constants/design_tokens.dart';
import 'package:portfolio/shared/constants/textstyles.dart';

/// Application theme configuration
/// Provides light and dark themes with responsive design support
class AppTheme {
  AppTheme._();

  /// Light theme configuration
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.bgColor,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.gradientPurple,
        surface: AppColors.bgColor,
        background: AppColors.bgColor,
        error: AppColors.gradientRed,
        onPrimary: AppColors.textWhite,
        onSecondary: AppColors.textWhite,
        onSurface: AppColors.primary,
        onBackground: AppColors.primary,
        onError: AppColors.textWhite,
      ),
      textTheme: _buildTextTheme(),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: AppColors.bgColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primary),
        titleTextStyle: AppStyles.subheading(),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textWhite,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.buttonPaddingHorizontal,
            vertical: DesignTokens.buttonPaddingVertical,
          ),
          minimumSize: const Size(0, DesignTokens.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.borderRadius0),
          ),
          textStyle: AppStyles.button(),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppStyles.button(color: AppColors.primary),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        border: UnderlineInputBorder(
          borderSide: BorderSide(
            color: AppColors.primary.withOpacity(AppColors.opacity80),
            width: 1.5,
          ),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: AppColors.primary.withOpacity(AppColors.opacity80),
            width: 1.5,
          ),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary, width: 2.0),
        ),
        labelStyle: AppStyles.body(
          color: AppColors.primary.withOpacity(AppColors.opacity80),
        ),
        hintStyle: AppStyles.body(
          color: AppColors.primary.withOpacity(AppColors.opacity80),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.bgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.borderRadius0),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.primary.withOpacity(AppColors.opacity20),
        thickness: 1.0,
        space: 1.0,
      ),
    );
  }

  /// Dark theme configuration (optional, can be added later)
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      colorScheme: ColorScheme.dark(
        primary: AppColors.textWhite,
        secondary: AppColors.gradientPurple,
        surface: AppColors.backgroundDark,
        background: AppColors.backgroundDark,
        error: AppColors.gradientRed,
        onPrimary: AppColors.primary,
        onSecondary: AppColors.textWhite,
        onSurface: AppColors.textWhite,
        onBackground: AppColors.textWhite,
        onError: AppColors.textWhite,
      ),
      textTheme: _buildTextTheme(isDark: true),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textWhite),
        titleTextStyle: AppStyles.subheading(color: AppColors.textWhite),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.textWhite,
          foregroundColor: AppColors.primary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.buttonPaddingHorizontal,
            vertical: DesignTokens.buttonPaddingVertical,
          ),
          minimumSize: const Size(0, DesignTokens.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.borderRadius0),
          ),
          textStyle: AppStyles.button(color: AppColors.primary),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        border: UnderlineInputBorder(
          borderSide: BorderSide(
            color: AppColors.textWhite.withOpacity(AppColors.opacity80),
            width: 1.5,
          ),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: AppColors.textWhite.withOpacity(AppColors.opacity80),
            width: 1.5,
          ),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.textWhite, width: 2.0),
        ),
        labelStyle: AppStyles.body(
          color: AppColors.textWhite.withOpacity(AppColors.opacity80),
        ),
        hintStyle: AppStyles.body(
          color: AppColors.textWhite.withOpacity(AppColors.opacity80),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.backgroundDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.borderRadius0),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.textWhite.withOpacity(AppColors.opacity20),
        thickness: 1.0,
        space: 1.0,
      ),
    );
  }

  /// Build text theme with Google Fonts
  static TextTheme _buildTextTheme({bool isDark = false}) {
    final textColor = isDark ? AppColors.textWhite : AppColors.primary;
    return GoogleFonts.ibmPlexSansTextTheme(
      TextTheme(
        displayLarge: AppStyles.displayLarge(color: textColor),
        displayMedium: AppStyles.heading(color: textColor),
        displaySmall: AppStyles.subheading(color: textColor),
        headlineLarge: AppStyles.titleLarge(color: textColor),
        headlineMedium: AppStyles.titleMedium(color: textColor),
        headlineSmall: AppStyles.titleSmall(color: textColor),
        titleLarge: AppStyles.titleLarge(color: textColor),
        titleMedium: AppStyles.titleMedium(color: textColor),
        titleSmall: AppStyles.titleSmall(color: textColor),
        bodyLarge: AppStyles.bodyLarge(color: textColor),
        bodyMedium: AppStyles.bodyMedium(color: textColor),
        bodySmall: AppStyles.bodySmall(color: textColor),
        labelLarge: AppStyles.button(color: textColor),
        labelMedium: AppStyles.body(color: textColor),
        labelSmall: AppStyles.bodySmall(color: textColor),
      ),
    );
  }
}
