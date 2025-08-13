import 'package:flutter/material.dart';

class SummaryChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final double elevation;
  final Color? shadowColor;

  const SummaryChip({
    required this.label,
    required this.count,
    required this.color,
    this.elevation = 2.0,
    this.shadowColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: elevation,
      shadowColor: shadowColor ?? color.withOpacity(0.3),
      borderRadius: BorderRadius.circular(16),
      child: Chip(
        label: Text('$count: $label'),
        labelStyle: TextStyle(color: color, fontWeight: FontWeight.bold),
        backgroundColor: color.withOpacity(0.1),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      ),
    );
  }
}
