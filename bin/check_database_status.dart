import 'package:oscars/services/database_service.dart';

void main() async {
  print('Checking database status...');

  try {
    await DatabaseService.instance.initialize();

    final count = DatabaseService.instance.getAllOscarWinners().length;
    print('Database has $count Oscar winner records');

    if (count == 0) {
      print('Database is empty - this is why the main screen shows no records');
      print('User needs to go to Settings and reload data from CSV');
    } else {
      print('Database has records - investigating why main screen is empty');

      // Show sample of years
      final records = DatabaseService.instance.getAllOscarWinners().take(5);
      for (final record in records) {
        print('Sample: ${record.yearFilm} - ${record.film} - ${record.name}');
      }
    }
  } catch (e) {
    print('Error checking database: $e');
  }
}
