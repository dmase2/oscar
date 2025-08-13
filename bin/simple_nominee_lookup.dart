import 'dart:io';

/// Simple CSV reader to check nominee lookup without Flutter dependencies
void main(List<String> args) async {
  if (args.isEmpty) {
    print('Usage: dart bin/simple_nominee_lookup.dart <nominee_id>');
    print('Example: dart bin/simple_nominee_lookup.dart nm0000102');
    exit(1);
  }

  final nomineeId = args[0];

  try {
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

    // Skip header
    final dataLines = lines.skip(1);
    final nominations = <Map<String, String>>[];

    // Find all nominations for this nominee ID
    for (final line in dataLines) {
      final fields = parseCSVLine(line);
      if (fields.length >= 10) {
        // Ensure we have enough fields
        final nomineeIds = fields[9]; // NomineeIds column

        // Check if this line contains our nominee ID
        if (nomineeIds.split('|').map((id) => id.trim()).contains(nomineeId)) {
          nominations.add({
            'Ceremony': fields[0],
            'Year': fields[1],
            'Category': fields[4],
            'Film': fields[5],
            'FilmId': fields[6],
            'Name': fields[7],
            'Nominees': fields[8],
            'NomineeIds': fields[9],
            'Winner': fields[10],
            'Detail': fields[11],
            'Note': fields[12],
          });
        }
      }
    }

    if (nominations.isEmpty) {
      print('No nominee found with ID: $nomineeId');
      exit(1);
    }

    // Print results
    final nomineeName = nominations.first['Name'] ?? 'Unknown';
    print('=== NOMINATIONS FOR $nomineeName (ID: $nomineeId) ===');
    print('Total nominations found: ${nominations.length}');
    print('');

    for (int i = 0; i < nominations.length; i++) {
      final nom = nominations[i];
      print('${i + 1}. ${nom['Film']} (${nom['Year']})');
      print('   Category: ${nom['Category']}');
      print('   Winner: ${nom['Winner'] == 'TRUE' ? "YES" : "NO"}');
      print('   Film ID: ${nom['FilmId']}');
      print('   Nominees: ${nom['Nominees']}');
      print('   Nominee IDs: ${nom['NomineeIds']}');
      if (nom['Note']?.isNotEmpty == true) {
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
