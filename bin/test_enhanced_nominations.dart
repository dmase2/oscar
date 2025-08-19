import 'package:oscars/services/database_service.dart';
import 'package:oscars/utils/nominee_parser.dart';

void main() async {
  print('Testing enhanced nominations display...');

  try {
    await DatabaseService.instance.initialize();

    final oscars = DatabaseService.instance.getAllOscarWinners();
    if (oscars.isEmpty) {
      print('No Oscar data found in database');
      return;
    }

    // Find a movie with multiple nominations
    final movieGroups = <String, List<dynamic>>{};
    for (var oscar in oscars.take(1000)) {
      // Limit for performance
      if (oscar.film.isNotEmpty && oscar.filmId.isNotEmpty) {
        final key = '${oscar.film}|${oscar.filmId}';
        movieGroups.putIfAbsent(key, () => []).add(oscar);
      }
    }

    // Find a movie with multiple nominations
    final multiNomMovie = movieGroups.entries
        .where((entry) => entry.value.length > 1)
        .first;

    final nominations = multiNomMovie.value;
    final movieTitle = nominations.first.film;
    final movieYear = nominations.first.yearFilm;

    print('\n=== MOVIE: $movieTitle ($movieYear) ===');
    print('Total nominations: ${nominations.length}');
    print('');

    for (var i = 0; i < nominations.length; i++) {
      final nomination = nominations[i];
      print(
        '${i + 1}. ${nomination.category} ${nomination.winner ? "🏆" : ""}',
      );

      // Parse nominees
      final nominees = NomineeParser.parseNominees(
        nomination.nominee,
        nomination.nomineeId,
      );

      if (nominees.isNotEmpty) {
        print('   Nominees:');
        for (var nominee in nominees) {
          final name = nominee['name'] ?? 'Unknown';
          final id = nominee['id'] ?? 'No ID';
          print('   - $name ($id)');

          // Test if we can look up this person
          if (id != 'No ID' && id.isNotEmpty) {
            final person = DatabaseService.instance.getNomineeById(id);
            if (person != null) {
              print('     ✓ Found in database: ${person.name}');
            } else {
              print('     ✗ Not found in database');
            }
          }
        }
      } else {
        print('   - ${nomination.name}');
      }
      print('');
    }

    print('Enhanced nominations display test completed successfully!');
  } catch (e) {
    print('Error testing nominations display: $e');
  }
}
