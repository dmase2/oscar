import 'package:oscars/services/database_service.dart';
import 'package:oscars/utils/nominee_parser.dart';

void main() async {
  print('Testing nominee parsing and lookup...');

  try {
    await DatabaseService.instance.initialize();

    final oscars = DatabaseService.instance.getAllOscarWinners();
    if (oscars.isEmpty) {
      print('No Oscar data found in database');
      return;
    }

    // Get a sample nomination with nominees
    final sampleOscar = oscars.firstWhere(
      (o) => o.nominee.isNotEmpty && o.nomineeId.isNotEmpty,
    );

    print('Sample Oscar: ${sampleOscar.film} (${sampleOscar.yearFilm})');
    print('Category: ${sampleOscar.category}');
    print('Nominees: ${sampleOscar.nominee}');
    print('Nominee IDs: ${sampleOscar.nomineeId}');

    // Test nominee parsing
    final nominees = NomineeParser.parseNominees(
      sampleOscar.nominee,
      sampleOscar.nomineeId,
    );

    print('\nParsed nominees:');
    for (var nominee in nominees) {
      print('- ${nominee['name']} (ID: ${nominee['id']})');

      // Test lookup
      final person = DatabaseService.instance.getNomineeById(nominee['id']!);
      if (person != null) {
        print('  Found person: ${person.name}');
      } else {
        print('  Person not found in database');
      }
    }

    print('\nNominee parsing and lookup test completed successfully!');
  } catch (e) {
    print('Error testing nominee functionality: $e');
  }
}
