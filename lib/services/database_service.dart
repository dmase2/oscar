import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/oscar_winner.dart';
import '../objectbox.g.dart';

class DatabaseService {
  static DatabaseService? _instance;
  static DatabaseService get instance => _instance ??= DatabaseService._();

  late final Store store;
  late final Box<OscarWinner> oscarBox;

  DatabaseService._();

  Future<void> initialize() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final databaseDirectory = Directory('${documentsDirectory.path}/objectbox');
    store = await openStore(directory: databaseDirectory.path);
    oscarBox = store.box<OscarWinner>();
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
}
