import 'package:flutter/material.dart';
import '../models/oscar_nominee.dart';

class OscarNomineeDetailScreen extends StatelessWidget {
  final OscarNominee nominee;
  final List<OscarNominee>? allNominees;
  final int? currentIndex;

  const OscarNomineeDetailScreen({
    super.key,
    required this.nominee,
    this.allNominees,
    this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          nominee.film,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text('Nominee: ${nominee.name}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Category: ${nominee.category}'),
            Text('Year: ${nominee.year}'),
            Text('Film: ${nominee.film}'),
            Text('Winner: ${nominee.winner ? "Yes" : "No"}'),
            if (nominee.detail.isNotEmpty) Text('Detail: ${nominee.detail}'),
            if (nominee.note.isNotEmpty) Text('Note: ${nominee.note}'),
            if (nominee.citation.isNotEmpty) Text('Citation: ${nominee.citation}'),
          ],
        ),
      ),
    );
  }
}
