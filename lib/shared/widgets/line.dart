import 'package:flutter/material.dart';

class StrikeLine extends StatelessWidget {
  const StrikeLine({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 65.0,
      height: 5.0,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFB147), Color(0xFFFF6C63), Color(0xFFB86ADF)],
          stops: [0, 52, 100],
        ),
      ),
    );
  }
}
