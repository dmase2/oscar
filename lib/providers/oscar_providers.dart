import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/oscar_winner.dart';
import '../services/database_service.dart';

final learnModeProvider = StateProvider<bool>((ref) => false);

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService.instance;
});

final oscarDataProvider = FutureProvider<List<OscarWinner>>((ref) async {
  final dbService = ref.read(databaseServiceProvider);
  // Only return current database contents, do not auto-repopulate from CSV
  return List<OscarWinner>.from(dbService.getAllOscarWinners());
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
  return sortedDecades;
});

final selectedDecadeProvider = StateProvider<int?>((ref) => null);
