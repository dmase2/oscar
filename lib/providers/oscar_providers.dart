import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/oscar_winner.dart';
import '../services/build_oscar_winner.dart';
import '../services/database_service.dart';

final learnModeProvider = StateProvider<bool>((ref) => false);

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService.instance;
});

// State provider to track database refresh state - increment to force reload
final databaseRefreshProvider = StateProvider<int>((ref) => 0);

final oscarDataProvider = FutureProvider<List<OscarWinner>>((ref) async {
  final dbService = ref.read(databaseServiceProvider);
  // Watch the refresh provider to trigger reloads when database changes
  ref.watch(databaseRefreshProvider);

  var data = List<OscarWinner>.from(dbService.getAllOscarWinners());
  print('DEBUG: oscarDataProvider loaded ${data.length} records');

  // Auto-load data if database is empty (first-time setup)
  if (data.isEmpty) {
    print('DEBUG: Database is empty - auto-loading data from CSV...');
    try {
      // Import the service class
      final winners =
          await OscarWinnerFromNomineeCsvService.loadOscarWinnersFromNomineeCsv();
      await dbService.insertOscarWinners(winners);
      data = List<OscarWinner>.from(dbService.getAllOscarWinners());
      print('DEBUG: Auto-loaded ${data.length} records from CSV');
    } catch (e) {
      print('DEBUG: Failed to auto-load data from CSV: $e');
      print('DEBUG: User will need to manually load via Settings');
    }
  }

  // Debug specific decades that user is asking about
  final years2000s = data
      .where((o) => o.yearFilm >= 2000 && o.yearFilm <= 2009)
      .length;
  final years2010s = data
      .where((o) => o.yearFilm >= 2010 && o.yearFilm <= 2019)
      .length;
  final years1990s = data
      .where((o) => o.yearFilm >= 1990 && o.yearFilm <= 1999)
      .length;
  final years2020s = data
      .where((o) => o.yearFilm >= 2020 && o.yearFilm <= 2029)
      .length;

  print(
    'DEBUG: Year breakdown - 1990s: $years1990s, 2000s: $years2000s, 2010s: $years2010s, 2020s: $years2020s',
  );

  if (data.isNotEmpty) {
    // Show sample years for debugging
    final yearSample = data.map((o) => o.yearFilm).toSet().take(10).toList()
      ..sort();
    print('DEBUG: Sample years in database: $yearSample');
  }

  return data;
});

// Enhanced helper provider to manually refresh oscar data with better logic
final refreshOscarDataProvider = Provider<void Function()>((ref) {
  return () {
    final dbService = ref.read(databaseServiceProvider);

    // Increment refresh counter to invalidate oscarDataProvider
    ref.read(databaseRefreshProvider.notifier).state++;

    // Provide helpful debug info
    final count = dbService.getAllOscarWinners().length;
    if (count == 0) {
      print('DEBUG: Refresh triggered but database is empty ($count records)');
      print('DEBUG: Use Settings > "Reload Database from CSV" to load data');
    } else {
      print('DEBUG: Oscar data providers refreshed ($count records available)');
    }
  };
});

final oscarsByDecadeProvider = FutureProvider.family<List<OscarWinner>, int>((
  ref,
  decade,
) async {
  final allOscars = await ref.read(oscarDataProvider.future);
  final endYear = decade + 9;
  return allOscars
      .where((o) => o.yearFilm >= decade && o.yearFilm <= endYear)
      .toList();
});

final availableDecadesProvider = FutureProvider<List<int>>((ref) async {
  final allOscars = await ref.read(oscarDataProvider.future);
  final decades = <int>{};
  for (final oscar in allOscars) {
    final decade = (oscar.yearFilm ~/ 10) * 10;
    decades.add(decade);
  }
  final sortedDecades = decades.toList()..sort();
  print('DEBUG: Available decades (from memory): $sortedDecades');

  // Debug specific decades user is asking about
  final has2000s = sortedDecades.contains(2000);
  final has2010s = sortedDecades.contains(2010);
  print('DEBUG: 2000s available: $has2000s, 2010s available: $has2010s');

  return sortedDecades;
});

final selectedDecadeProvider = StateProvider<int?>((ref) => null);
