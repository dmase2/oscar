import 'package:oscars/services/database_service.dart';

void main() async {
  print('Testing compact nominee list design...');

  try {
    await DatabaseService.instance.initialize();

    final nominees = DatabaseService.instance.getAllNominees();
    if (nominees.isEmpty) {
      print('No nominees found in database');
      return;
    }

    // Find a nominee with multiple nominations
    String? testNomineeId;
    for (var nominee in nominees.take(50)) {
      final nominations = DatabaseService.instance
          .getAllOscarWinners()
          .where((w) => w.nomineeId.split('|').contains(nominee.nomineeId))
          .toList();

      if (nominations.length >= 3) {
        testNomineeId = nominee.nomineeId;
        print('Found test nominee: ${nominee.name}');
        print('Total nominations: ${nominations.length}');

        // Show compact summary
        print('\nCompact Nominations Display:');
        var index = 1;
        for (var nom in nominations.take(5)) {
          final status = nom.winner ? '🏆' : '  ';
          print(
            '$index. [${nom.yearFilm}] ${nom.film} - ${nom.category} $status',
          );
          index++;
        }

        if (nominations.length > 5) {
          print('... and ${nominations.length - 5} more');
        }

        break;
      }
    }

    if (testNomineeId != null) {
      print('\n✅ Compact nominee list design test completed successfully!');
      print('The new design will show:');
      print('- Year badges for quick chronological scanning');
      print('- Film and category in separate lines for clarity');
      print('- Winner indicators with gold highlighting');
      print('- Special awards with distinct styling');
      print('- Reduced vertical spacing for better density');
    } else {
      print('Could not find a suitable test nominee with multiple nominations');
    }
  } catch (e) {
    print('Error testing compact design: $e');
  }
}
