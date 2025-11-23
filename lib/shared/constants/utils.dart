import 'package:flutter/material.dart';

class AppUtils {
  SizedBox vSpace({double size = 20.0}) {
    return SizedBox(height: size);
  }

  SizedBox hSpace({double size = 20.0}) {
    return SizedBox(width: size);
  }

  LinearGradient appGradient = LinearGradient(
    colors: [Color(0xFFFFB147), Color(0xFFFF6C63), Color(0xFFB86ADF)],
    stops: [0, 52, 100],
  );
}
