import '../models/box_office_entry.dart';
import '../models/nominee.dart';
import '../models/oscar_winner.dart';
import '../models/poster_cache_entry.dart';
import '../objectbox.dart';
import '../objectbox.g.dart';

class DatabaseService {
  static DatabaseService? _instance;
  static DatabaseService get instance => _instance ??= DatabaseService._();

  late final Store store;
  late final Box<OscarWinner> oscarBox;
  late final Box<PosterCacheEntry> posterCacheBox;
  late final Box<Nominee> nomineeBox;
  late final Box<BoxOfficeEntry> boxOfficeEntryBox;

  DatabaseService._();

  Future<void> initialize() async {
    // Initialize ObjectBox store singleton (shared for all entities)
    final objectBox = await ObjectBox.create();
    store = objectBox.store;
    oscarBox = store.box<OscarWinner>();
    posterCacheBox = store.box<PosterCacheEntry>();
    nomineeBox = store.box<Nominee>();
    boxOfficeEntryBox = store.box<BoxOfficeEntry>();
  }

  Future<void> insertOscarWinner(OscarWinner winner) async {
    oscarBox.put(winner);
  }

  Future<void> insertOscarWinners(List<OscarWinner> winners) async {
    oscarBox.putMany(winners);
  }

  List<OscarWinner> getAllOscarWinners() {
    return oscarBox.getAll();
  }

  List<OscarWinner> getOscarWinnersByDecade(int startYear) {
    final endYear = startYear + 9;
    final query = oscarBox
        .query(
          OscarWinner_.yearFilm.greaterOrEqual(startYear) &
              OscarWinner_.yearFilm.lessOrEqual(endYear),
        )
        .build();
    final results = query.find();
    query.close();
    return results;
  }

  List<OscarWinner> getOscarWinnersByYear(int year) {
    final query = oscarBox.query(OscarWinner_.yearFilm.equals(year)).build();
    final results = query.find();
    query.close();
    return results;
  }

  void close() {
    store.close();
  }

  bool get isEmpty => oscarBox.isEmpty();

  // Nominee methods
  Future<void> insertNominee(Nominee nominee) async {
    nomineeBox.put(nominee);
  }

  Future<void> insertNominees(List<Nominee> nominees) async {
    nomineeBox.putMany(nominees);
  }

  List<Nominee> getAllNominees() {
    return nomineeBox.getAll();
  }

  Nominee? getNomineeById(String nomineeId) {
    final query = nomineeBox
        .query(Nominee_.nomineeId.equals(nomineeId))
        .build();
    final result = query.findFirst();
    query.close();
    return result;
  }

  List<Nominee> getNomineesByName(String name) {
    final query = nomineeBox.query(Nominee_.name.contains(name)).build();
    final results = query.find();
    query.close();
    return results;
  }

  // Clear nominees table for testing
  Future<void> clearNominees() async {
    nomineeBox.removeAll();
  }
}
