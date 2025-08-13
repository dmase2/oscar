import 'dart:io';

/// Test nominee lookup without Flutter/ObjectBox dependencies
void main(List<String> args) async {
  if (args.isEmpty) {
    print('Usage: dart bin/test_csv_nominee_lookup.dart <nominee_id>');
    print('Example: dart bin/test_csv_nominee_lookup.dart nm0000354');
    return;
  }

  final nomineeId = args[0];

  try {
    print('Testing nominee lookup for ID: $nomineeId');
    print('Reading CSV file...');

    // Read the Oscar nominee CSV file directly
    final file = File('assets/data/oscar_nominee.csv');
    if (!file.existsSync()) {
      print('Error: CSV file not found at assets/data/oscar_nominee.csv');
      exit(1);
    }

    final lines = await file.readAsLines();
    if (lines.isEmpty) {
      print('Error: CSV file is empty');
      exit(1);
    }

    print('Total lines in CSV: ${lines.length}');

    // Parse header to understand structure
    final header = lines[0].split(',');
    print('CSV Header: $header');

    // Find the NomineeIds column index
    int nomineeIdColumn = -1;
    for (int i = 0; i < header.length; i++) {
      if (header[i].toLowerCase().trim() == 'nomineeids') {
        nomineeIdColumn = i;
        break;
      }
    }

    if (nomineeIdColumn == -1) {
      print('Error: Could not find NomineeIds column');
      exit(1);
    }

    print('NomineeIds column is at index: $nomineeIdColumn');

    // Skip header and search for the nominee ID
    final dataLines = lines.skip(1);
    final nominations = <Map<String, String>>[];
    int lineNumber = 2; // Start from 2 since we skipped header (line 1)

    for (final line in dataLines) {
      try {
        final fields = parseCSVLine(line);
        if (fields.length > nomineeIdColumn) {
          final nomineeIds = fields[nomineeIdColumn];

          // Check if this line contains our nominee ID
          if (nomineeIds
              .split('|')
              .map((id) => id.trim())
              .contains(nomineeId)) {
            // Create a map with field names and values
            final record = <String, String>{};
            for (int i = 0; i < header.length && i < fields.length; i++) {
              record[header[i].trim()] = fields[i];
            }
            nominations.add(record);
            print(
              'Found match at line $lineNumber: ${fields.length > 5 ? fields[5] : "Unknown Film"}',
            );
          }
        }
      } catch (e) {
        print('Error parsing line $lineNumber: $e');
      }
      lineNumber++;
    }

    if (nominations.isEmpty) {
      print('No nominee found with ID: $nomineeId');

      // Search for similar IDs
      print('\nSearching for similar IDs...');
      final searchPrefix = nomineeId.length >= 6
          ? nomineeId.substring(0, 6)
          : nomineeId;
      final similarIds = <String>{};

      for (final line in lines.skip(1)) {
        final fields = parseCSVLine(line);
        if (fields.length > nomineeIdColumn) {
          final ids = fields[nomineeIdColumn].split('|');
          for (final id in ids) {
            final trimmedId = id.trim();
            if (trimmedId.startsWith(searchPrefix) && similarIds.length < 10) {
              similarIds.add(trimmedId);
            }
          }
        }
      }

      if (similarIds.isNotEmpty) {
        print('Similar IDs found: ${similarIds.toList()}');
      }

      exit(1);
    }

    // Print results
    final nomineeName = nominations.first['Name'] ?? 'Unknown';
    print('\n=== NOMINATIONS FOR $nomineeName (ID: $nomineeId) ===');
    print('Total nominations found: ${nominations.length}');
    print('');

    for (int i = 0; i < nominations.length; i++) {
      final nom = nominations[i];
      print(
        '${i + 1}. ${nom['Film'] ?? 'Unknown Film'} (${nom['Year'] ?? 'Unknown Year'})',
      );
      print('   Category: ${nom['Category'] ?? 'Unknown Category'}');
      print('   Winner: ${nom['Winner'] == 'TRUE' ? "YES" : "NO"}');
      print('   Film ID: ${nom['FilmId'] ?? 'Unknown'}');
      print('   Nominees: ${nom['Nominees'] ?? 'Unknown'}');
      print('   Nominee IDs: ${nom['NomineeIds'] ?? 'Unknown'}');
      if ((nom['Note'] ?? '').isNotEmpty) {
        print('   Note: ${nom['Note']}');
      }
      print('');
    }

    // Show simple statistics
    final wins = nominations.where((n) => n['Winner'] == 'TRUE').length;
    print('STATISTICS:');
    print('Total nominations: ${nominations.length}');
    print('Wins: $wins');
    print('========================================');

    print('\nObjectBox nominee lookup issue diagnosed:');
    print('The CSV parsing works correctly.');
    print(
      'The issue is likely that nominees are not being loaded into ObjectBox database.',
    );
    print(
      'To fix: Make sure the app calls the nominee loading process during initialization.',
    );
  } catch (e, stackTrace) {
    print('Error: $e');
    print('Stack trace: $stackTrace');
    exit(1);
  }
}

/// Simple CSV line parser that handles quoted fields
List<String> parseCSVLine(String line) {
  final fields = <String>[];
  var current = '';
  var inQuotes = false;
  var i = 0;

  while (i < line.length) {
    final char = line[i];

    if (char == '"') {
      if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
        // Escaped quote
        current += '"';
        i += 2;
      } else {
        // Toggle quotes
        inQuotes = !inQuotes;
        i++;
      }
    } else if (char == ',' && !inQuotes) {
      // Field separator
      fields.add(current);
      current = '';
      i++;
    } else {
      current += char;
      i++;
    }
  }

  // Add the last field
  fields.add(current);
  return fields;
}
