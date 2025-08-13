import '../models/oscar_winner.dart';
import '../services/database_service.dart';
import 'oscar_repository.dart';

/// ObjectBox implementation of the Oscar repository
class ObjectBoxOscarRepository implements OscarRepository {
  final DatabaseService _databaseService;

  ObjectBoxOscarRepository(this._databaseService);

  @override
  Future<List<OscarWinner>> getAllOscars() async {
    return _databaseService.getAllOscarWinners();
  }

  @override
  Future<List<OscarWinner>> getOscarsByFilm(String filmName) async {
    final allOscars = await getAllOscars();
    return allOscars
        .where(
          (oscar) =>
              oscar.film.trim().toLowerCase() == filmName.trim().toLowerCase(),
        )
        .toList();
  }

  @override
  Future<OscarWinner?> getOscarById(String id) async {
    final allOscars = await getAllOscars();
    try {
      return allOscars.firstWhere((oscar) => oscar.id.toString() == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<OscarWinner>> getOscarsByYear(int year) async {
    final allOscars = await getAllOscars();
    return allOscars.where((oscar) => oscar.yearFilm == year).toList();
  }

  @override
  Future<List<OscarWinner>> getOscarsByCategory(String category) async {
    final allOscars = await getAllOscars();
    return allOscars
        .where(
          (oscar) =>
              oscar.category.toLowerCase().contains(category.toLowerCase()),
        )
        .toList();
  }

  @override
  Future<List<OscarWinner>> getSpecialAwards() async {
    final allOscars = await getAllOscars();
    return allOscars
        .where((oscar) => oscar.className?.toLowerCase() == 'special')
        .toList();
  }

  @override
  Future<List<OscarWinner>> getWinners() async {
    final allOscars = await getAllOscars();
    return allOscars.where((oscar) => oscar.winner).toList();
  }

  @override
  Future<List<OscarWinner>> getNominees() async {
    final allOscars = await getAllOscars();
    return allOscars.where((oscar) => !oscar.winner).toList();
  }

  @override
  Future<List<OscarWinner>> searchOscars(String query) async {
    final allOscars = await getAllOscars();
    final lowerQuery = query.toLowerCase();

    return allOscars
        .where(
          (oscar) =>
              oscar.film.toLowerCase().contains(lowerQuery) ||
              oscar.name.toLowerCase().contains(lowerQuery) ||
              oscar.nominee.toLowerCase().contains(lowerQuery) ||
              oscar.category.toLowerCase().contains(lowerQuery),
        )
        .toList();
  }

  @override
  Future<List<OscarWinner>> getOscarsByNomineeId(String nomineeId) async {
    final allOscars = await getAllOscars();
    return allOscars
        .where(
          (oscar) =>
              oscar.nomineeId.split('|').any((id) => id.trim() == nomineeId),
        )
        .toList();
  }
}
