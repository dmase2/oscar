import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../models/nominee.dart';
import '../models/oscar_winner.dart';
import 'database_service.dart';

class OscarWinnerFromNomineeCsvService {
  static Future<List<OscarWinner>> loadOscarWinnersFromNomineeCsv({
    String inputCsv = 'assets/data/oscar_nominee.csv',
  }) async {
    // NOTE: For multiline fields (e.g., notes/citations), the CSV must be RFC 4180-compliant:
    // fields with newlines must be quoted. CsvToListConverter with eol: null will handle this.
    final input = await rootBundle.loadString(inputCsv);
    final rows =
        const CsvToListConverter(
          shouldParseNumbers: false,
          allowInvalid: true,
        ).convert(
          input,
          eol: null,
        ); // Let the parser auto-detect line endings and handle multiline fields
    if (rows.isEmpty) return [];

    // Normalize headers
    final header = rows.first
        .map((h) => h.toString().trim().toLowerCase())
        .toList();
    final List<OscarWinner> winners = [];
    final List<Nominee> nomineesList = [];
    final Map<String, Nominee> nomineeMap = {};
    int skippedEmptyOrShort = 0;
    int skippedMissingFields = 0;
    int skippedParsingErrors = 0;

    for (int i = 1; i < rows.length; i++) {
      final row = rows[i];

      // Skip empty or too-short rows
      if (row.isEmpty || row.length < 5) {
        skippedEmptyOrShort++;
        print('Skipped row $i: Too short or empty');
        continue;
      }

      // Map columns safely
      final map = {
        for (var j = 0; j < header.length && j < row.length; j++)
          header[j]: row[j]?.toString() ?? '',
      };

      // Validate critical fields
      if (map['year'] == null ||
          map['canonicalcategory'] == null ||
          map['name'] == null) {
        skippedMissingFields++;
        print('Skipped row $i: Missing critical fields');
        continue;
      }

      final winnerRaw = map['winner'];
      final winnerBool =
          winnerRaw != null && winnerRaw.trim().toLowerCase() == 'true';

      // Handle year split if contains '/'
      int yearFilm = 0;
      int yearCeremony = 0;
      final yearRaw = map['year'] ?? '';
      if (yearRaw.contains('/')) {
        final parts = yearRaw.split('/');
        yearFilm = int.tryParse(parts[0].trim()) ?? 0;
        // Assuming ceremony is the next year
      } else {
        yearFilm = int.tryParse(yearRaw) ?? 0;
      }
      yearCeremony = yearFilm + 1;

      try {
        final winner = OscarWinner(
          yearFilm: yearFilm,
          yearCeremony: yearCeremony,
          ceremony: int.tryParse(map['ceremony'] ?? '') ?? 0,
          category: map['category'] ?? '',
          canonCategory: map['canonicalcategory'] ?? '',
          name: map['name'] ?? '',
          film: map['film'] ?? '',
          filmId: map['filmid'] ?? '',
          nominee: map['nominees'] ?? '',
          nomineeId: map['nomineeids'] ?? '',
          winner: winnerBool,
          detail: map['detail'] ?? '',
          note: map['note'] ?? '',
          citation: map['citation'] ?? '',
          domesticBoxOffice: 0.0,
          foreignBoxOffice: 0.0,
          totalBoxOffice: 0.0,
          rottenTomatoesScore: 0,
          className: map['class'] ?? '',
        );
        winners.add(winner);

        // Build nominees from nominee and nomineeId fields
        final nomineeNames = (map['nominees'] ?? '')
            .split('|')
            .map((n) => n.trim())
            .where((n) => n.isNotEmpty)
            .toList();
        final nomineeIds = (map['nomineeids'] ?? '')
            .split('|')
            .map((n) => n.trim())
            .where((n) => n.isNotEmpty)
            .toList();
        for (int j = 0; j < nomineeNames.length && j < nomineeIds.length; j++) {
          final name = nomineeNames[j];
          final id = nomineeIds[j];
          if (name.isNotEmpty && id.isNotEmpty) {
            final key = '$name|$id';
            if (!nomineeMap.containsKey(key)) {
              final nominee = Nominee(name: name, nomineeId: id, filmIds: []);
              nomineeMap[key] = nominee;
              print(
                '[DEBUG] added nominee: $name (ID: $id) at ${nominee.createdAt}',
              );
            }
            nomineeMap[key]!.filmIds.add(winner.filmId);
            nomineeMap[key]!.updateAuditTrail();
          }
        }

        // Debug print for Best Actor in 2020s
        if (winner.canonCategory.toUpperCase().contains('ACTOR') &&
            winner.yearFilm >= 2020) {
          print(
            '[DEBUG] 2020s ACTOR: year=${winner.yearFilm}, canonCategory=${winner.canonCategory}, name=${winner.name}, film=${winner.film}',
          );
        }
        print(
          'Added row $i: '
          '${map['year']}/${map['canonicalcategory']} - ${map['name']} (${map['film']})',
        );
      } catch (e) {
        skippedParsingErrors++;
        print('Skipped row $i: Exception $e');
        continue;
      }
    }

    nomineesList.addAll(nomineeMap.values);
    print('Total unique nominees loaded: ${nomineesList.length}');

    // Save nominees to ObjectBox database
    try {
      await DatabaseService.instance.insertNominees(nomineesList);
      print('Successfully saved ${nomineesList.length} nominees to database');
    } catch (e) {
      print('Error saving nominees to database: $e');
    }

    print('Total rows in CSV: ${rows.length}');
    print('Summary of skipped rows:');
    print('  Empty or too-short rows: $skippedEmptyOrShort');
    print('  Rows with missing fields: $skippedMissingFields');
    print('  Rows with parsing errors: $skippedParsingErrors');
    print('Total rows added: ${winners.length}');

    return winners;
  }
}
