import '../models/nominee.dart';
import '../models/oscar_winner.dart';
import '../services/database_service.dart';

/// Service to generate deduplicated nomination statistics for a nominee.
class NomineeNominationsService {
  /// Returns nomination statistics from ObjectBox nominee table
  /// - nominations: count of unique (category, yearFilm) pairs (excluding special awards)
  /// - wins: count of unique (category, yearFilm) pairs where winner == true (excluding special awards)
  /// - specialAwards: count of unique special awards
  static ({int nominations, int wins, int specialAwards}) getNomineeNominations(
    List<OscarWinner> allWinners,
    String nomineeId,
  ) {
    final allMovies = allWinners
        .where(
          (w) =>
              w.nomineeId.split('|').map((n) => n.trim()).contains(nomineeId),
        )
        .toList();

    // Separate regular nominations from special awards using className field
    final regularNominations = allMovies
        .where((m) => m.className?.toLowerCase() != 'special')
        .toList();
    final specialAwardsList = allMovies
        .where((m) => m.className?.toLowerCase() == 'special')
        .toList();

    // Count unique (category, year) pairs for regular nominations and wins
    final nominationPairs = <String>{};
    final winPairs = <String>{};
    for (final movie in regularNominations) {
      final normalizedCategory = movie.category.trim().toLowerCase();
      final key = '$normalizedCategory|${movie.yearFilm}';
      nominationPairs.add(key);
      if (movie.winner) winPairs.add(key);
    }

    // Count unique (category, year) pairs for special awards
    final specialAwardsSet = <String>{};
    for (final movie in specialAwardsList) {
      final key = '${movie.category.trim().toLowerCase()}|${movie.yearFilm}';
      specialAwardsSet.add(key);
    }

    return (
      nominations: nominationPairs.length,
      wins: winPairs.length,
      specialAwards: specialAwardsSet.length,
    );
  }

  /// Get all nominees from ObjectBox
  static List<Nominee> getAllNominees() {
    final db = DatabaseService.instance;
    return db.getAllNominees();
  }

  /// Get nominee by ID from ObjectBox
  static Nominee? getNomineeById(String nomineeId) {
    final db = DatabaseService.instance;
    return db.getNomineeById(nomineeId);
  }

  /// Get nominees by name from ObjectBox
  static List<Nominee> getNomineesByName(String name) {
    final db = DatabaseService.instance;
    return db.getNomineesByName(name);
  }
}
