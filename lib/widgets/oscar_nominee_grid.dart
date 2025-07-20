import 'package:flutter/material.dart';
import '../models/oscar_nominee.dart';
import 'oscar_nominee_card.dart';

class OscarNomineeGrid extends StatelessWidget {
  final List<OscarNominee> nominees;

  const OscarNomineeGrid({super.key, required this.nominees});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: nominees.length,
      itemBuilder: (context, index) {
        final nominee = nominees[index];
        return OscarNomineeCard(
          nominee: nominee,
          allNominees: nominees,
          currentIndex: index,
        );
      },
    );
  }
}
