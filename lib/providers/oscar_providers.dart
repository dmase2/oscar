import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/oscar_winner.dart';
import '../services/csv_data_service.dart';
import '../services/database_service.dart';

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService.instance;
});

final oscarDataProvider = FutureProvider<List<OscarWinner>>((ref) async {
  final dbService = ref.read(databaseServiceProvider);
  if (dbService.isEmpty) {
    final oscarWinners = await CsvDataService.loadOscarData();
    // Optionally fetch poster URLs if needed, using film and yearFilm
    // for (final winner in oscarWinners) {
    //   winner.posterUrl = await PosterService.getPosterUrl(winner.film, winner.yearFilm);
    // }
    await dbService.insertOscarWinners(oscarWinners);
  }
  return dbService.getAllOscarWinners();
});

final oscarsByDecadeProvider = FutureProvider.family<List<OscarWinner>, int>((
  ref,
  decade,
) async {
  final dbService = ref.read(databaseServiceProvider);
  await ref.read(oscarDataProvider.future);
  return dbService.getOscarWinnersByDecade(decade);
});

final availableDecadesProvider = FutureProvider<List<int>>((ref) async {
  // Load directly from CSV to ensure all decades are included
  final oscarWinners = await CsvDataService.loadOscarData();
  final decades = <int>{};
  for (final oscar in oscarWinners) {
    final decade = (oscar.yearFilm ~/ 10) * 10;
    decades.add(decade);
  }
  final sortedDecades = decades.toList()..sort();
  print('DEBUG: Available decades: $sortedDecades');
  return sortedDecades;
});

final selectedDecadeProvider = StateProvider<int>((ref) {
  final decadesAsync = ref.watch(availableDecadesProvider);
  return decadesAsync.maybeWhen(
    data: (decades) => decades.isNotEmpty ? decades.last : 2020,
    orElse: () => 2020,
  );
});
