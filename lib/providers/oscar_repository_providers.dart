import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/oscar_winner.dart';
import '../repositories/objectbox_oscar_repository.dart';
import '../repositories/oscar_repository.dart';
import '../services/database_service.dart';
import '../services/oscar_service.dart';

/// Provider for the database service
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService.instance;
});

/// Provider for the Oscar repository
final oscarRepositoryProvider = Provider<OscarRepository>((ref) {
  final databaseService = ref.read(databaseServiceProvider);
  return ObjectBoxOscarRepository(databaseService);
});

/// Provider for all Oscar data using the repository pattern
final oscarDataRepositoryProvider = FutureProvider<List<OscarWinner>>((
  ref,
) async {
  final repository = ref.read(oscarRepositoryProvider);
  return await repository.getAllOscars();
});

/// Provider for Oscar data filtered by decade using the repository pattern
final oscarsByDecadeRepositoryProvider =
    FutureProvider.family<List<OscarWinner>, int>((ref, decade) async {
      final repository = ref.read(oscarRepositoryProvider);
      final allOscars = await repository.getAllOscars();
      final endYear = decade + 9;
      return allOscars
          .where((o) => o.yearFilm >= decade && o.yearFilm <= endYear)
          .toList();
    });

/// Provider for available decades using the repository pattern
final availableDecadesRepositoryProvider = FutureProvider<List<int>>((
  ref,
) async {
  final repository = ref.read(oscarRepositoryProvider);
  final allOscars = await repository.getAllOscars();
  final decades = <int>{};
  for (final oscar in allOscars) {
    final decade = (oscar.yearFilm ~/ 10) * 10;
    decades.add(decade);
  }
  final sortedDecades = decades.toList()..sort();
  return sortedDecades;
});

/// Provider for special awards using the repository pattern
final specialAwardsRepositoryProvider = FutureProvider<List<OscarWinner>>((
  ref,
) async {
  final repository = ref.read(oscarRepositoryProvider);
  return await repository.getSpecialAwards();
});

/// Provider for winners only using the repository pattern
final winnersRepositoryProvider = FutureProvider<List<OscarWinner>>((
  ref,
) async {
  final repository = ref.read(oscarRepositoryProvider);
  return await repository.getWinners();
});

/// Provider for searching Oscars using the repository pattern
final searchOscarsRepositoryProvider =
    FutureProvider.family<List<OscarWinner>, String>((ref, query) async {
      final repository = ref.read(oscarRepositoryProvider);
      return await repository.searchOscars(query);
    });

/// Provider for Oscars by film using the repository pattern
final oscarsByFilmRepositoryProvider =
    FutureProvider.family<List<OscarWinner>, String>((ref, filmName) async {
      final repository = ref.read(oscarRepositoryProvider);
      return await repository.getOscarsByFilm(filmName);
    });

/// Provider for Oscars by nominee ID using the repository pattern
final oscarsByNomineeIdRepositoryProvider =
    FutureProvider.family<List<OscarWinner>, String>((ref, nomineeId) async {
      final repository = ref.read(oscarRepositoryProvider);
      return await repository.getOscarsByNomineeId(nomineeId);
    });

/// Provider for the Oscar service
final oscarServiceProvider = Provider<OscarService>((ref) {
  final repository = ref.read(oscarRepositoryProvider);
  return OscarService(repository);
});
