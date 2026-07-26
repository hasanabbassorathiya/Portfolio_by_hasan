import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Core palette — Kinetic Brutalism
  static const Color deep = Color(0xFF09090B);
  static const Color base = Color(0xFF18181B);
  static const Color surface = Color(0xFF27272A);
  static const Color muted = Color(0xFF3F3F46);
  static const Color border = Color(0xFF52525B);

  // Accent — Electric Blue
  static const Color accent = Color(0xFF38BDF8);
  static const Color accentHover = Color(0xFF60A5FA);
  static const Color accentSubtle = Color(0x1A38BDF8);
  static const Color accentGlow = Color(0x3338BDF8);

  // Text
  static const Color textPrimary = Color(0xFFFAFAFA);
  static const Color textSecondary = Color(0xFFA1A1AA);
  static const Color textMuted = Color(0xFF71717A);

  // Glass
  static const Color glassFill = Color(0x0DFFFFFF);
  static const Color glassBorder = Color(0x1AFFFFFF);

  // Gradients
  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF38BDF8), Color(0xFF818CF8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGlow = LinearGradient(
    colors: [Color(0x3338BDF8), Color(0x0038BDF8)],
    begin: Alignment.center,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient darkVignette = LinearGradient(
    colors: [Color(0x0009090B), Color(0xFF09090B)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Status
  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
}
