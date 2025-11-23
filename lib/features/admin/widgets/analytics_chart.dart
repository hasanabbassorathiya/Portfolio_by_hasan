/// Analytics chart widget placeholder
/// Can be enhanced with chart library like fl_chart
import 'package:flutter/material.dart';

// Placeholder for future chart implementation
class AnalyticsChart extends StatelessWidget {
  final Map<String, dynamic> data;

  const AnalyticsChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Text('Chart visualization (can be enhanced with fl_chart)'),
      ),
    );
  }
}
