import 'package:oscars/services/build_oscar_winner.dart';
import 'package:oscars/services/database_service.dart';

/// Test ObjectBox nominee lookup
void main(List<String> args) async {
  if (args.isEmpty) {
    print('Usage: dart bin/test_objectbox_lookup.dart <nominee_id>');
    print('Example: dart bin/test_objectbox_lookup.dart nm0000354');
    return;
  }

  final nomineeId = args[0];

  try {
    print('Initializing database...');
    await DatabaseService.instance.initialize();

    // Check if we have any nominees in the database
    final allNominees = DatabaseService.instance.getAllNominees();
    print('Total nominees in database: ${allNominees.length}');

    if (allNominees.isEmpty) {
      print('No nominees found in database. Loading from CSV...');

      // Load Oscar winners (this will also load nominees now)
      final winners =
          await OscarWinnerFromNomineeCsvService.loadOscarWinnersFromNomineeCsv();
      await DatabaseService.instance.insertOscarWinners(winners);
      print('Loaded ${winners.length} Oscar winners');

      // Check nominees again
      final nomineesAfterLoad = DatabaseService.instance.getAllNominees();
      print('Total nominees after loading: ${nomineesAfterLoad.length}');
    }

    // Now try to find the specific nominee
    print('\nLooking for nominee: $nomineeId');
    final nominee = DatabaseService.instance.getNomineeById(nomineeId);

    if (nominee != null) {
      print('Found nominee: ${nominee.name} (ID: ${nominee.nomineeId})');
      print('Films: ${nominee.filmIds}');

      // Get their nominations
      final allWinners = DatabaseService.instance.getAllOscarWinners();
      final nominations = allWinners
          .where(
            (w) =>
                w.nomineeId.split('|').map((n) => n.trim()).contains(nomineeId),
          )
          .toList();

      print('Total nominations: ${nominations.length}');
      for (final nom in nominations) {
        print(
          '- ${nom.film} (${nom.yearFilm}) - ${nom.category} ${nom.winner ? "[WINNER]" : ""}',
        );
      }
    } else {
      print('Nominee not found with ID: $nomineeId');

      // Try to find similar IDs
      print('\nSearching for similar nominee IDs...');
      final allNominees = DatabaseService.instance.getAllNominees();
      final similar = allNominees
          .where((n) => n.nomineeId.contains(nomineeId.substring(0, 6)))
          .take(5);
      if (similar.isNotEmpty) {
        print('Similar IDs found:');
        for (final n in similar) {
          print('- ${n.nomineeId}: ${n.name}');
        }
      }
    }
  } catch (e, stackTrace) {
    print('Error: $e');
    print('Stack trace: $stackTrace');
  }
}
