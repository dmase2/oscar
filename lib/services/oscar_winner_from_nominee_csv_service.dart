import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../models/oscar_winner.dart';

class OscarWinnerFromNomineeCsvService {
  static Future<List<OscarWinner>> loadOscarWinnersFromNomineeCsv({
    String inputCsv = 'assets/data/oscar_nominee.csv',
  }) async {
    final input = await rootBundle.loadString(inputCsv);
    final rows = const CsvToListConverter().convert(input, eol: '\n');
    if (rows.isEmpty) return [];
    final header = rows.first.map((h) => h.toString().trim()).toList();
    final List<OscarWinner> winners = [];
    for (int i = 1; i < rows.length; i++) {
      final row = rows[i];
      final map = {
        for (var j = 0; j < header.length; j++) header[j]: row[j].toString(),
      };
      final winnerRaw = map['Winner'] ?? map['winner'];
      final winnerBool =
          winnerRaw != null && winnerRaw.trim().toLowerCase() == 'true';

      // Handle year split if contains '/'
      int yearFilm = 0;
      int yearCeremony = 0;
      final yearRaw = map['Year'] ?? '';
      if (yearRaw.contains('/')) {
        final parts = yearRaw.split('/');
        yearFilm = int.tryParse(parts[0].trim()) ?? 0;
        // Assuming ceremony is the next year
      } else {
        yearFilm = int.tryParse(yearRaw) ?? 0;
      }
      yearCeremony = yearFilm + 1;
      winners.add(
        OscarWinner(
          yearFilm: yearFilm,
          yearCeremony: yearCeremony,
          ceremony: int.tryParse(map['Ceremony'] ?? map['ceremony'] ?? '') ?? 0,
          category: map['Category'] ?? '',
          canonCategory:
              map['CanonicalCategory'] ?? map['canon_category'] ?? '',
          name: map['Name'] ?? '',
          film: map['Film'] ?? '',
          filmId: map['FilmId'] ?? '',
          nominee: map['Nominees'] ?? '',
          nomineeId: map['NomineeIds'] ?? '',
          winner: winnerBool,
          detail: map['Detail'] ?? '',
          note: map['Note'] ?? '',
          citation: map['Citation'] ?? '',
          domesticBoxOffice: null,
          foreignBoxOffice: null,
          totalBoxOffice: null,
          rottenTomatoesScore: null,
        ),
      );
    }
    return winners;
  }
}
