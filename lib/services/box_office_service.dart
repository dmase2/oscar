import 'package:csv/csv.dart';
import 'package:flutter/services.dart';

import '../models/box_office_entry.dart';
import '../objectbox.g.dart';
import 'database_service.dart';

class BoxOfficeService {
  static BoxOfficeService? _instance;
  static BoxOfficeService get instance => _instance ??= BoxOfficeService._();

  BoxOfficeService._();

  /// Initialize box office data by loading from CSV if the database is empty
  Future<void> initializeBoxOfficeData() async {
    final box = DatabaseService.instance.boxOfficeEntryBox;

    if (box.isEmpty()) {
      print('🔄 BoxOfficeService: Database is empty, loading from CSV...');
      await _loadBoxOfficeDataFromCSV();
    } else {
      print(
        '🔄 BoxOfficeService: Database has ${box.count()} entries, skipping CSV load',
      );
    }

    // Always debug print first few entries to verify data
    debugPrintSampleEntries();
  }

  /// Load box office data from the CSV file in assets
  Future<void> _loadBoxOfficeDataFromCSV() async {
    try {
      final csvData = await rootBundle.loadString(
        'assets/data/all_boxoffice.csv',
      );

      final rows = const CsvToListConverter().convert(csvData, eol: '\n');
      final entries = rows.skip(1).map((row) => _parseCSVRow(row)).toList();

      final box = DatabaseService.instance.boxOfficeEntryBox;
      box.putMany(entries);

      print('✅ Loaded ${entries.length} box office entries from CSV');

      // Debug: print first few entries to verify parsing
      if (entries.isNotEmpty) {
        print('🔍 Debug: First 3 parsed entries:');
        for (int i = 0; i < 3 && i < entries.length; i++) {
          final entry = entries[i];
          print(
            '  $i: ${entry.title} -> D:${entry.domestic}, I:${entry.international}, W:${entry.worldwide}',
          );
        }
      }
    } catch (e) {
      print('❌ Error loading box office data: $e');
      rethrow;
    }
  }

  /// Parse a single CSV row into a BoxOfficeEntry
  BoxOfficeEntry _parseCSVRow(List<dynamic> row) {
    // New format: Year, Title, Domestic, International, Worldwide, ImdbID, URL
    if (row.length >= 7) {
      final title = row[1].toString();

      // Strip non-digits from currency strings
      final domesticStr = row[2].toString().replaceAll(RegExp(r'[^0-9]'), '');
      final domestic = domesticStr.isEmpty ? 0 : int.parse(domesticStr);

      final internationalStr = row[3].toString().replaceAll(
        RegExp(r'[^0-9]'),
        '',
      );
      final international = internationalStr.isEmpty
          ? 0
          : int.parse(internationalStr);

      final worldwideStr = row[4].toString().replaceAll(RegExp(r'[^0-9]'), '');
      final worldwide = worldwideStr.isEmpty ? 0 : int.parse(worldwideStr);

      // Extract numeric part of IMDb ID (e.g., 'tt1234567' -> '1234567')
      final imdbIdStr = row[5].toString().replaceAll(RegExp(r'[^0-9]'), '');
      return BoxOfficeEntry(
        id: int.parse(imdbIdStr),
        title: title,
        domestic: domestic,
        international: international,
        worldwide: worldwide,
        url: row[6].toString(),
      );
    }

    // Legacy format handling for backward compatibility
    final title = row[0].toString();

    // Strip non-digits from currency strings
    final domesticStr = row[1].toString().replaceAll(RegExp(r'[^0-9]'), '');
    int domestic = domesticStr.isEmpty ? 0 : int.parse(domesticStr);
    int international = 0;
    int worldwide = 0;

    // Check if we have the old format with separate International and Worldwide columns
    if (row.length >= 6) {
      // Old format: Title, Domestic, International, Worldwide, ImdbID, URL
      final internationalStr = row[2].toString().replaceAll(
        RegExp(r'[^0-9]'),
        '',
      );
      international = internationalStr.isEmpty
          ? 0
          : int.parse(internationalStr);

      final worldwideStr = row[3].toString().replaceAll(RegExp(r'[^0-9]'), '');
      worldwide = worldwideStr.isEmpty ? 0 : int.parse(worldwideStr);

      // Extract numeric part of IMDb ID (e.g., 'tt1234567' -> '1234567')
      final imdbIdStr = row[4].toString().replaceAll(RegExp(r'[^0-9]'), '');
      return BoxOfficeEntry(
        id: int.parse(imdbIdStr),
        title: title,
        domestic: domestic,
        international: international,
        worldwide: worldwide,
        url: row[5].toString(),
      );
    } else {
      // Legacy format: Title, Domestic, Worldwide, ImdbID, URL
      final worldwideStr = row[2].toString().replaceAll(RegExp(r'[^0-9]'), '');
      worldwide = worldwideStr.isEmpty ? 0 : int.parse(worldwideStr);
      // Calculate international as worldwide minus domestic
      international = (worldwide - domestic).clamp(0, worldwide);

      // Extract numeric part of IMDb ID (e.g., 'tt1234567' -> '1234567')
      final imdbIdStr = row[3].toString().replaceAll(RegExp(r'[^0-9]'), '');
      return BoxOfficeEntry(
        id: int.parse(imdbIdStr),
        title: title,
        domestic: domestic,
        international: international,
        worldwide: worldwide,
        url: row[4].toString(),
      );
    }
  }

  /// Get all box office entries
  List<BoxOfficeEntry> getAllBoxOfficeEntries() {
    return DatabaseService.instance.boxOfficeEntryBox.getAll();
  }

  /// Get box office entry by IMDb ID
  BoxOfficeEntry? getBoxOfficeEntryById(int imdbId) {
    final box = DatabaseService.instance.boxOfficeEntryBox;
    return box.get(imdbId);
  }

  /// Get box office entries for a specific title (case-insensitive)
  List<BoxOfficeEntry> getBoxOfficeEntriesByTitle(String title) {
    final box = DatabaseService.instance.boxOfficeEntryBox;
    final query = box
        .query(BoxOfficeEntry_.title.contains(title, caseSensitive: false))
        .build();
    final results = query.find();
    query.close();
    return results;
  }

  /// Force reload box office data from CSV (useful for testing or updates)
  Future<void> reloadBoxOfficeData() async {
    final box = DatabaseService.instance.boxOfficeEntryBox;
    box.removeAll(); // Clear existing data
    await _loadBoxOfficeDataFromCSV();
  }

  /// Clear all box office data
  Future<void> clearBoxOfficeData() async {
    final box = DatabaseService.instance.boxOfficeEntryBox;
    box.removeAll();
  }

  /// Get count of box office entries
  int getBoxOfficeEntryCount() {
    return DatabaseService.instance.boxOfficeEntryBox.count();
  }

  /// Debug method to print sample entries with their values
  void debugPrintSampleEntries() {
    final entries = getAllBoxOfficeEntries();
    print('🔍 Debug: Total box office entries: ${entries.length}');

    if (entries.isNotEmpty) {
      print('🔍 Debug: First 3 entries:');
      for (int i = 0; i < 3 && i < entries.length; i++) {
        final entry = entries[i];
        print('  Entry $i: ${entry.title}');
        print('    Domestic: ${entry.domestic}');
        print('    International: ${entry.international}');
        print('    Worldwide: ${entry.worldwide}');
      }
    }
  }
}
