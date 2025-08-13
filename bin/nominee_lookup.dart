import 'dart:io';

import 'package:oscars/services/database_service.dart';
import 'package:oscars/services/nominee_nominations_service.dart';

/// Command line tool to lookup nominees by ID and print all their films
void main(List<String> args) async {
  if (args.isEmpty) {
    print('Usage: dart bin/nominee_lookup.dart <nominee_id>');
    print('Example: dart bin/nominee_lookup.dart nm0000102');
    exit(1);
  }

  final nomineeId = args[0];

  try {
    // Initialize database
    await DatabaseService.instance.initialize();

    // Look up nominee
    final nominee = DatabaseService.instance.getNomineeById(nomineeId);
    if (nominee == null) {
      print('No nominee found with ID: $nomineeId');
      exit(1);
    }

    // Get all nominations
    final allWinners = DatabaseService.instance.getAllOscarWinners();
    final nominations = allWinners
        .where(
          (w) =>
              w.nomineeId.split('|').map((n) => n.trim()).contains(nomineeId),
        )
        .toList();

    // Print results
    print('=== NOMINATIONS FOR ${nominee.name} (ID: $nomineeId) ===');
    print('Total nominations found: ${nominations.length}');
    print('Films in nominee record: ${nominee.filmIds}');
    print('');

    if (nominations.isEmpty) {
      print('No nominations found for this nominee.');
      return;
    }

    for (int i = 0; i < nominations.length; i++) {
      final nom = nominations[i];
      print('${i + 1}. ${nom.film} (${nom.yearFilm})');
      print('   Category: ${nom.category}');
      print('   Winner: ${nom.winner ? "YES" : "NO"}');
      print('   Film ID: ${nom.filmId}');
      print('   Nominees: ${nom.nominee}');
      print('   Nominee IDs: ${nom.nomineeId}');
      if (nom.note.isNotEmpty) {
        print('   Note: ${nom.note}');
      }
      print('');
    }

    // Show statistics
    final stats = NomineeNominationsService.getNomineeNominations(
      allWinners,
      nomineeId,
    );
    print('STATISTICS:');
    print('Regular nominations: ${stats.nominations}');
    print('Wins: ${stats.wins}');
    print('Special awards: ${stats.specialAwards}');
    print('========================================');
  } catch (e, stackTrace) {
    print('Error: $e');
    print('Stack trace: $stackTrace');
    exit(1);
  }
}
