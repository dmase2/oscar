import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oscars/services/build_oscar_winner.dart';

import '../models/oscar_winner.dart';
import '../providers/oscar_providers.dart';
import '../providers/shade_opacity_provider.dart';
import '../widgets/oscars_app_drawer_widget.dart';

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
    final List<OscarWinner> winners =
        await OscarWinnerFromNomineeCsvService.loadOscarWinnersFromNomineeCsv();
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
      drawer: const OscarsAppDrawer(selected: 'settings'),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            // Persistent slider for shade opacity in learning mode
            const Text(
              'Learning Mode Shade Opacity',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Consumer(
              builder: (context, ref, _) {
                final opacity = ref.watch(shadeOpacityProvider);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Slider(
                      value: opacity,
                      min: 0.1,
                      max: 1.0,
                      divisions: 18,
                      label: opacity.toStringAsFixed(2),
                      onChanged: (value) {
                        ref
                            .read(shadeOpacityProvider.notifier)
                            .setOpacity(value);
                      },
                    ),
                    Text('Current: ${(opacity * 100).toStringAsFixed(0)}%'),
                  ],
                );
              },
            ),
            const Divider(height: 32),
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
                dbService.getAllOscarWinners();
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
