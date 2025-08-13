import '../models/oscar_winner.dart';

/// Abstract repository interface for Oscar data operations
abstract class OscarRepository {
  /// Get all Oscar winners
  Future<List<OscarWinner>> getAllOscars();

  /// Get Oscars by film name
  Future<List<OscarWinner>> getOscarsByFilm(String filmName);

  /// Get Oscar by ID
  Future<OscarWinner?> getOscarById(String id);

  /// Get Oscars by year
  Future<List<OscarWinner>> getOscarsByYear(int year);

  /// Get Oscars by category
  Future<List<OscarWinner>> getOscarsByCategory(String category);

  /// Get special awards
  Future<List<OscarWinner>> getSpecialAwards();

  /// Get winners only
  Future<List<OscarWinner>> getWinners();

  /// Get nominees only (non-winners)
  Future<List<OscarWinner>> getNominees();

  /// Search Oscars by query
  Future<List<OscarWinner>> searchOscars(String query);

  /// Get Oscars by nominee ID
  Future<List<OscarWinner>> getOscarsByNomineeId(String nomineeId);
}
