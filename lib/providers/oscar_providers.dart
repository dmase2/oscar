import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oscars/services/build_oscar_winner.dart';

import '../models/oscar_winner.dart';
import '../services/database_service.dart';

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService.instance;
});

final oscarDataProvider = FutureProvider<List<OscarWinner>>((ref) async {
  final dbService = ref.read(databaseServiceProvider);
  if (dbService.isEmpty) {
    final oscarWinners =
        await OscarWinnerFromNomineeCsvService.loadOscarWinnersFromNomineeCsv();
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
  // Use ObjectBox DB to get all available decades
  final dbService = ref.read(databaseServiceProvider);
  await ref.read(oscarDataProvider.future); // Ensure DB is populated
  final oscarWinners = dbService.getAllOscarWinners();
  final decades = <int>{};
  for (final oscar in oscarWinners) {
    final decade = (oscar.yearFilm ~/ 10) * 10;
    decades.add(decade);
  }
  final sortedDecades = decades.toList()..sort();
  print('DEBUG: Available decades (from DB): $sortedDecades');
  return sortedDecades;
});

final selectedDecadeProvider = StateProvider<int>((ref) {
  final decadesAsync = ref.watch(availableDecadesProvider);
  return decadesAsync.maybeWhen(
    data: (decades) => decades.isNotEmpty ? decades.last : 2020,
    orElse: () => 2020,
  );
});

final availableYearsProvider = FutureProvider<List<int>>((ref) async {
  final dbService = ref.read(databaseServiceProvider);
  await ref.read(oscarDataProvider.future);
  final oscarWinners = dbService.getAllOscarWinners();
  final years = <int>{};
  for (final oscar in oscarWinners) {
    years.add(oscar.yearFilm);
  }
  final sortedYears = years.toList()..sort((a, b) => b.compareTo(a));
  return sortedYears;
});

final selectedYearProvider = StateProvider<int?>((ref) => null);

final oscarsByDecadeAndYearProvider =
    FutureProvider.family<List<OscarWinner>, Map<String, int?>>((
      ref,
      params,
    ) async {
      final dbService = ref.read(databaseServiceProvider);
      await ref.read(oscarDataProvider.future);
      final decade = params['decade'];
      final year = params['year'];
      var winners = decade != null
          ? dbService.getOscarWinnersByDecade(decade)
          : dbService.getAllOscarWinners();
      if (year != null) {
        winners = winners.where((w) => w.yearFilm == year).toList();
      }
      return winners;
    });
