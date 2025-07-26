import 'package:flutter/material.dart';

class SummaryChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const SummaryChip({
    required this.label,
    required this.count,
    required this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text('$count: $label'),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.bold),
      backgroundColor: color.withOpacity(0.1),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    );
  }
}
