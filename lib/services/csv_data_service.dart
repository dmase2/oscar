import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;

import '../models/oscar_winner.dart';
import '../services/oscar_song_service.dart';

class CsvDataService {
  /// Looks up IMDb IDs for each film in the CSV and appends them to a new file.
  static Future<void> appendImdbIdsToCsv({
    String inputCsv = 'assets/data/oscar_winner.csv',
    String outputCsv = 'assets/data/oscar_winner_with_imdb.csv',
    String omdbApiKey = 'b925d287',
  }) async {
    final input = File(inputCsv).readAsStringSync();
    final rows = const CsvToListConverter().convert(input, eol: '\n');
    final header = List<String>.from(rows.first);
    if (!header.contains('imdbId')) header.add('imdbId');

    final outputRows = [header];
    for (var i = 1; i < rows.length; i++) {
      final row = rows[i];
      final rowMap = Map<String, dynamic>.fromIterables(header, row);
      final title = rowMap['film']?.toString() ?? '';
      final year = rowMap['year_film']?.toString() ?? '';
      final url = Uri.parse(
        'http://www.omdbapi.com/?apikey=$omdbApiKey&t=${Uri.encodeComponent(title)}&y=$year',
      );
      String imdbId = '';
      try {
        final response = await http.get(url);
        if (response.statusCode == 200) {
          final data = response.body;
          final imdbIdMatch = RegExp(r'"imdbID":"(tt\d+)"').firstMatch(data);
          if (imdbIdMatch != null) {
            imdbId = imdbIdMatch.group(1) ?? '';
          }
        }
      } catch (_) {}
      rowMap['imdbId'] = imdbId;
      outputRows.add(header.map((h) => (rowMap[h] ?? '').toString()).toList());
      await Future.delayed(const Duration(milliseconds: 200));
      print('Processed: $title ($year) -> $imdbId');
    }
    final output = const ListToCsvConverter().convert(outputRows);
    File(outputCsv).writeAsStringSync(output);
    print('Done! IMDb IDs appended to $outputCsv');
  }

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

        final domesticBoxOffice = double.tryParse(
          map['domestic_box_office'] ?? '',
        );
        final foreignBoxOffice = double.tryParse(
          map['foreign_box_office'] ?? '',
        );
        final totalBoxOffice = double.tryParse(map['total_box_office'] ?? '');
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
          filmId: '',
          nominee: '',
          nomineeId: '',
          detail: '',
          note: '',
          citation: '',
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
          filmId: '',
          nominee: '',
          nomineeId: '',
          detail: '',
          note: '',
          citation: '',
        );
        oscarWinners.add(oscarWinner);
      } catch (e) {
        continue;
      }
    }
    return oscarWinners;
  }
}
