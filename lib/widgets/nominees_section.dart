import 'package:flutter/material.dart';

import 'nominee_chip.dart';

class NomineesSection extends StatelessWidget {
  final List<Map<String, String>> nominees;
  final Function(String name, String id) onNomineePressed;

  const NomineesSection({
    super.key,
    required this.nominees,
    required this.onNomineePressed,
  });

  @override
  Widget build(BuildContext context) {
    if (nominees.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              'Nominee(s):',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: nominees
                  .map(
                    (nominee) => NomineeChip(
                      nominee: nominee,
                      onPressed: onNomineePressed,
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
