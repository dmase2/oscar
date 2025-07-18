import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../models/oscar_winner.dart';
import '../services/oscar_song_service.dart';

class CsvDataService {
  static List<OscarWinner> parseCsvData(List<List<dynamic>> csvTable) {
    final List<OscarWinner> oscarWinners = [];
    if (csvTable.isEmpty) return oscarWinners;
    final header = csvTable[0].map((h) => h.toString().trim()).toList();
    for (int i = 1; i < csvTable.length; i++) {
      final row = csvTable[i];
      try {
        final map = {
          for (var j = 0; j < header.length; j++) header[j]: row[j].toString(),
        };
        final winnerRaw = map['winner'];
        final winnerBool =
            winnerRaw != null && winnerRaw.trim().toLowerCase() == 'true';
        String name = map['name'] ?? '';
        final category = map['category'] ?? '';
        final canonCategory = map['canon_category'] ?? '';
        final film = map['film'] ?? '';
        final yearFilm = int.tryParse(map['year_film'] ?? '') ?? 0;
        // If Best Original Song, prepend song title

        final domesticBoxOffice = double.tryParse(map['domestic_box_office'] ?? '') ?? null;
        final foreignBoxOffice = double.tryParse(map['foreign_box_office'] ?? '') ?? null;
        final totalBoxOffice = double.tryParse(map['total_box_office'] ?? '') ?? null;
        final oscarWinner = OscarWinner(
          yearFilm: yearFilm,
          yearCeremony: int.tryParse(map['year_ceremony'] ?? '') ?? 0,
          ceremony: int.tryParse(map['ceremony'] ?? '') ?? 0,
          category: category,
          canonCategory: canonCategory,
          name: name,
          film: film,
          winner: winnerBool,
          domesticBoxOffice: domesticBoxOffice,
          foreignBoxOffice: foreignBoxOffice,
          totalBoxOffice: totalBoxOffice,
        );
        oscarWinners.add(oscarWinner);
      } catch (e) {
        continue;
      }
    }
    return oscarWinners;
  }

  static Future<List<OscarWinner>> loadOscarData() async {
    final csvString = await rootBundle.loadString(
      'assets/data/oscar_winner.csv',
    );
    final csvTable = const CsvToListConverter(eol: '\n').convert(csvString);
    // Load song info once for efficiency
    final songList = await OscarSongService.loadSongs();
    // Patch parseCsvData to append song title for Best Original Song
    final List<OscarWinner> oscarWinners = [];
    if (csvTable.isEmpty) return oscarWinners;
    final header = csvTable[0].map((h) => h.toString().trim()).toList();
    final dummySong = OscarSongInfo(
      year: 0,
      songTitle: '',
      movieTitle: '',
      musicAuthor: '',
      lyricAuthor: '',
      imdbId: '',
      tmdbId: '',
    );
    for (int i = 1; i < csvTable.length; i++) {
      final row = csvTable[i];
      try {
        final map = {
          for (var j = 0; j < header.length; j++) header[j]: row[j].toString(),
        };
        final winnerRaw = map['winner'];
        final winnerBool =
            winnerRaw != null && winnerRaw.trim().toLowerCase() == 'true';
        String name = map['name'] ?? '';
        final category = map['category'] ?? '';
        final canonCategory = map['canon_category'] ?? '';
        final film = map['film'] ?? '';
        final yearFilm = int.tryParse(map['year_film'] ?? '') ?? 0;
        // If Best Original Song, prepend song title
        if (canonCategory.toUpperCase().contains('ORIGINAL SONG')) {
          final match = songList.firstWhere(
            (song) =>
                song.movieTitle.trim().toLowerCase() ==
                    film.trim().toLowerCase() &&
                song.year == yearFilm,
            orElse: () => dummySong,
          );
          if (match != dummySong && match.songTitle.isNotEmpty) {
            name = '${match.songTitle} - $name';
          }
        }
        final oscarWinner = OscarWinner(
          yearFilm: yearFilm,
          yearCeremony: int.tryParse(map['year_ceremony'] ?? '') ?? 0,
          ceremony: int.tryParse(map['ceremony'] ?? '') ?? 0,
          category: category,
          canonCategory: canonCategory,
          name: name,
          film: film,
          winner: winnerBool,
        );
        oscarWinners.add(oscarWinner);
      } catch (e) {
        continue;
      }
    }
    return oscarWinners;
  }
}
