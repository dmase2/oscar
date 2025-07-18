import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/oscar_winner.dart';
import '../providers/oscar_providers.dart';
import '../services/csv_data_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _clearDatabase(BuildContext context, WidgetRef ref) async {
    final dbService = ref.read(databaseServiceProvider);
    dbService.oscarBox.removeAll();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('ObjectBox database cleared.')),
    );
  }

  Future<void> _reloadDatabase(BuildContext context, WidgetRef ref) async {
    final dbService = ref.read(databaseServiceProvider);
    dbService.oscarBox.removeAll();
    final List<OscarWinner> winners = await CsvDataService.loadOscarData();
    await dbService.insertOscarWinners(winners);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Reloaded ${winners.length} records from CSV.')),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () => _clearDatabase(context, ref),
              child: const Text('Clear ObjectBox Database'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _reloadDatabase(context, ref),
              child: const Text('Reload Database from CSV'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final dbService = ref.read(databaseServiceProvider);
                final records = dbService.getAllOscarWinners();
                for (final record in records) {
                  print(
                    'OscarWinner: ${record.yearFilm}, ${record.film}, ${record.name}, Winner: ${record.winner.toString()}',
                  );
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Printed ObjectBox records to console.'),
                  ),
                );
              },
              child: const Text('Print ObjectBox Database'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                SystemNavigator.pop();
              },
              child: const Text('Exit Application'),
            ),
          ],
        ),
      ),
    );
  }
}
