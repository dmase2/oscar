import 'dart:io';

import 'package:csv/csv.dart';

void main() async {
  // Read the CSV file
  final file = File('assets/data/all_boxoffice.csv');
  final csvData = await file.readAsString();

  final rows = const CsvToListConverter().convert(csvData, eol: '\n');

  print('Total rows: ${rows.length}');
  print('Header: ${rows[0]}');
  print('First data row: ${rows[1]}');
  print('Row length: ${rows[1].length}');

  // Test parsing first few rows
  for (int i = 1; i <= 3; i++) {
    final row = rows[i];
    print('\n--- Row $i ---');
    print('Raw row: $row');

    if (row.length >= 7) {
      final title = row[1].toString();
      print('Title: $title');

      // Test domestic parsing
      final domesticRaw = row[2].toString();
      final domesticStr = domesticRaw.replaceAll(RegExp(r'[^0-9]'), '');
      final domestic = domesticStr.isEmpty ? 0 : int.parse(domesticStr);
      print(
        'Domestic raw: "$domesticRaw" -> cleaned: "$domesticStr" -> parsed: $domestic',
      );

      // Test international parsing
      final internationalRaw = row[3].toString();
      final internationalStr = internationalRaw.replaceAll(
        RegExp(r'[^0-9]'),
        '',
      );
      final international = internationalStr.isEmpty
          ? 0
          : int.parse(internationalStr);
      print(
        'International raw: "$internationalRaw" -> cleaned: "$internationalStr" -> parsed: $international',
      );

      // Test worldwide parsing
      final worldwideRaw = row[4].toString();
      final worldwideStr = worldwideRaw.replaceAll(RegExp(r'[^0-9]'), '');
      final worldwide = worldwideStr.isEmpty ? 0 : int.parse(worldwideStr);
      print(
        'Worldwide raw: "$worldwideRaw" -> cleaned: "$worldwideStr" -> parsed: $worldwide',
      );

      // Test IMDb ID parsing
      final imdbIdRaw = row[5].toString();
      final imdbIdStr = imdbIdRaw.replaceAll(RegExp(r'[^0-9]'), '');
      print('IMDb ID raw: "$imdbIdRaw" -> cleaned: "$imdbIdStr"');

      final url = row[6].toString();
      print('URL: "$url"');
    } else {
      print('Row too short: ${row.length} columns');
    }
  }
}
