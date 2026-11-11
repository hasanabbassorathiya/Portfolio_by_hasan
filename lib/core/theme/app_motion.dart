import 'package:flutter/material.dart';

/// Motion choreography constants — spring-like mass, never linear/ease-in-out.
class AppMotion {
  AppMotion._();

  /// Primary product curve: heavy, fluid deceleration (matches
  /// cubic-bezier(0.32, 0.72, 0, 1) from the design spec).
  static const Cubic swiftOut = Cubic(0.32, 0.72, 0, 1);

  /// Gentle settle for hover states.
  static const Cubic settle = Cubic(0.22, 1, 0.36, 1);

  /// Dramatic entrance for hero-scale elements.
  static const Cubic reveal = Cubic(0.16, 1, 0.3, 1);

  static const Duration fast = Duration(milliseconds: 300);
  static const Duration base = Duration(milliseconds: 450);
  static const Duration slow = Duration(milliseconds: 650);
  static const Duration entrance = Duration(milliseconds: 850);
}
