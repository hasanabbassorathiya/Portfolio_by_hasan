import 'package:flutter/material.dart';

/// Ethereal Glass palette — OLED black, vantablack cores, white hairlines.
class AppColors {
  AppColors._();

  // Core surfaces
  static const Color deep = Color(0xFF050505); // OLED background
  static const Color base = Color(0xFF0A0A0B); // vantablack card core
  static const Color surface = Color(0xFF121214); // elevated core
  static const Color muted = Color(0xFF1C1C1F); // pressed fills
  static const Color elevated = Color(0xFF232326);

  // Hairline borders (white at low alpha — never solid gray)
  static const Color hairline = Color(0x1AFFFFFF); // white/10
  static const Color hairlineSoft = Color(0x0FFFFFFF); // white/6
  static const Color hairlineStrong = Color(0x26FFFFFF); // white/15

  // Legacy aliases (admin screens still reference these)
  static const Color border = hairline;

  // Accent — electric blue family
  static const Color accent = Color(0xFF38BDF8);
  static const Color accentHover = Color(0xFF7DD3FC);
  static const Color accentSubtle = Color(0x1438BDF8);
  static const Color accentGlow = Color(0x3338BDF8);

  // Mesh-gradient orb tints (used at low alpha, heavily blurred)
  static const Color orbIndigo = Color(0xFF6366F1);
  static const Color orbEmerald = Color(0xFF34D399);
  static const Color orbCyan = Color(0xFF22D3EE);

  // Text
  static const Color textPrimary = Color(0xFFFAFAFA);
  static const Color textSecondary = Color(0xFFA1A1AA);
  static const Color textMuted = Color(0xFF71717A);

  // Glass (backdrop-blur overlays only)
  static const Color glassFill = Color(0x0DFFFFFF); // white/5
  static const Color white08 = Color(0x14FFFFFF); // white/8 — hovered shells
  static const Color glassBorder = Color(0x1AFFFFFF); // white/10
  static const Color glassScrim = Color(0xB3050505); // black/70

  // Ambient shadows — large, diffused, never hard-offset
  static const List<BoxShadow> shadowAmbient = [
    BoxShadow(
      color: Color(0x59000000), // black/35
      offset: Offset(0, 24),
      blurRadius: 80,
    ),
  ];

  static const List<BoxShadow> shadowLifted = [
    BoxShadow(
      color: Color(0x66000000), // black/40
      offset: Offset(0, 32),
      blurRadius: 120,
    ),
  ];

  // Inset top highlight applied to card cores (machined-glass edge)
  static const BoxShadow insetHighlight = BoxShadow(
    color: Color(0x26FFFFFF), // white/15
    offset: Offset(0, 1),
  );

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
    colors: [Color(0x00050505), Color(0xFF050505)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Status
  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
}
