import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  static TextStyle displayLarge([Color? color]) => GoogleFonts.spaceGrotesk(
    fontSize: 72,
    fontWeight: FontWeight.w900,
    color: color ?? AppColors.textPrimary,
    height: 0.95,
    letterSpacing: -2,
  );

  static TextStyle displayMedium([Color? color]) => GoogleFonts.spaceGrotesk(
    fontSize: 48,
    fontWeight: FontWeight.w800,
    color: color ?? AppColors.textPrimary,
    height: 1.0,
    letterSpacing: -1,
  );

  static TextStyle displaySmall([Color? color]) => GoogleFonts.spaceGrotesk(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    color: color ?? AppColors.textPrimary,
    height: 1.1,
  );

  static TextStyle headline([Color? color]) => GoogleFonts.spaceGrotesk(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: color ?? AppColors.textPrimary,
    height: 1.2,
  );

  static TextStyle title([Color? color]) => GoogleFonts.spaceGrotesk(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: color ?? AppColors.textPrimary,
  );

  static TextStyle body([Color? color]) => GoogleFonts.spaceGrotesk(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: color ?? AppColors.textSecondary,
    height: 1.7,
  );

  static TextStyle small([Color? color]) => GoogleFonts.spaceGrotesk(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: color ?? AppColors.textMuted,
    height: 1.5,
  );

  static TextStyle label([Color? color]) => GoogleFonts.spaceGrotesk(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: color ?? AppColors.accent,
    letterSpacing: 4,
  );
}
