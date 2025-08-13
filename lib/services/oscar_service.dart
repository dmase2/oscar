import '../models/oscar_winner.dart';
import '../repositories/oscar_repository.dart';

/// Service class that provides high-level operations for Oscar data
/// Uses the repository pattern for data access
class OscarService {
  final OscarRepository _repository;

  OscarService(this._repository);

  /// Get all nominations for a specific film
  Future<List<OscarWinner>> getFilmNominations(String filmName) async {
    return await _repository.getOscarsByFilm(filmName);
  }

  /// Get nomination statistics for a film
  Future<FilmNominationStats> getFilmStats(String filmName) async {
    final nominations = await getFilmNominations(filmName);
    final wins = nominations.where((n) => n.winner).length;
    final specialAwards = nominations
        .where((n) => n.className?.toLowerCase() == 'special')
        .length;

    return FilmNominationStats(
      totalNominations: nominations.length,
      wins: wins,
      specialAwards: specialAwards,
      nominations: nominations,
    );
  }

  /// Get all nominations for a specific nominee
  Future<List<OscarWinner>> getNomineeNominations(String nomineeId) async {
    return await _repository.getOscarsByNomineeId(nomineeId);
  }

  /// Search for Oscars with advanced filtering
  Future<List<OscarWinner>> searchWithFilters({
    String? query,
    int? year,
    String? category,
    bool? winnersOnly,
    bool? specialAwardsOnly,
  }) async {
    List<OscarWinner> results;

    if (query != null && query.isNotEmpty) {
      results = await _repository.searchOscars(query);
    } else {
      results = await _repository.getAllOscars();
    }

    // Apply filters
    if (year != null) {
      results = results.where((o) => o.yearFilm == year).toList();
    }

    if (category != null && category.isNotEmpty) {
      results = results
          .where(
            (o) => o.category.toLowerCase().contains(category.toLowerCase()),
          )
          .toList();
    }

    if (winnersOnly == true) {
      results = results.where((o) => o.winner).toList();
    }

    if (specialAwardsOnly == true) {
      results = results
          .where((o) => o.className?.toLowerCase() == 'special')
          .toList();
    }

    return results;
  }

  /// Get Oscars grouped by decade
  Future<Map<int, List<OscarWinner>>> getOscarsByDecades() async {
    final allOscars = await _repository.getAllOscars();
    final Map<int, List<OscarWinner>> decadeGroups = {};

    for (final oscar in allOscars) {
      final decade = (oscar.yearFilm ~/ 10) * 10;
      decadeGroups.putIfAbsent(decade, () => []).add(oscar);
    }

    return decadeGroups;
  }

  /// Get summary statistics
  Future<OscarSummaryStats> getSummaryStats() async {
    final allOscars = await _repository.getAllOscars();
    final winners = allOscars.where((o) => o.winner).length;
    final nominees = allOscars.where((o) => !o.winner).length;
    final specialAwards = allOscars
        .where((o) => o.className?.toLowerCase() == 'special')
        .length;

    final years = allOscars.map((o) => o.yearFilm).toSet();
    final categories = allOscars.map((o) => o.category).toSet();

    return OscarSummaryStats(
      totalEntries: allOscars.length,
      winners: winners,
      nominees: nominees,
      specialAwards: specialAwards,
      yearsSpanned: years.length,
      uniqueCategories: categories.length,
      earliestYear: years.isEmpty ? 0 : years.reduce((a, b) => a < b ? a : b),
      latestYear: years.isEmpty ? 0 : years.reduce((a, b) => a > b ? a : b),
    );
  }
}

/// Statistics for a specific film's nominations
class FilmNominationStats {
  final int totalNominations;
  final int wins;
  final int specialAwards;
  final List<OscarWinner> nominations;

  const FilmNominationStats({
    required this.totalNominations,
    required this.wins,
    required this.specialAwards,
    required this.nominations,
  });
}

/// Overall Oscar statistics
class OscarSummaryStats {
  final int totalEntries;
  final int winners;
  final int nominees;
  final int specialAwards;
  final int yearsSpanned;
  final int uniqueCategories;
  final int earliestYear;
  final int latestYear;

  const OscarSummaryStats({
    required this.totalEntries,
    required this.winners,
    required this.nominees,
    required this.specialAwards,
    required this.yearsSpanned,
    required this.uniqueCategories,
    required this.earliestYear,
    required this.latestYear,
  });
}
