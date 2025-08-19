import 'package:oscars/services/build_oscar_winner.dart';
import 'package:oscars/services/database_service.dart';

/// Debug the 2000s-2010s data loading and filtering issue
void main() async {
  print('=== Debugging 2000s-2010s Data Issue ===\n');
  
  try {
    // Initialize database
    await DatabaseService.instance.initialize();
    
    print('1. Checking current database state...');
    final currentData = DatabaseService.instance.getAllOscarWinners();
    print('   Current database records: ${currentData.length}');
    
    if (currentData.isEmpty) {
      print('   Database is empty, loading from CSV...');
      final winners = await OscarWinnerFromNomineeCsvService.loadOscarWinnersFromNomineeCsv();
      await DatabaseService.instance.insertOscarWinners(winners);
      print('   Loaded ${winners.length} records from CSV');
    }
    
    print('\n2. Analyzing year distribution...');
    final allData = DatabaseService.instance.getAllOscarWinners();
    
    // Group by decade
    final decadeCount = <int, int>{};
    final yearRange = <int, int>{};
    
    for (final record in allData) {
      final year = record.yearFilm;
      final decade = (year ~/ 10) * 10;
      
      decadeCount[decade] = (decadeCount[decade] ?? 0) + 1;
      yearRange[decade] = yearRange[decade] ?? year;
      if (year < yearRange[decade]!) yearRange[decade] = year;
    }
    
    print('   Decade Distribution:');
    print('   Decade | Count | Sample Year');
    print('   -------|-------|------------');
    
    final sortedDecades = decadeCount.keys.toList()..sort();
    for (final decade in sortedDecades) {
      print('   ${decade}s  | ${decadeCount[decade]!.toString().padLeft(5)} | ${yearRange[decade]}');
    }
    
    print('\n3. Focusing on 2000s-2010s data...');
    
    // Check 2000s data
    final data2000s = allData.where((o) => o.yearFilm >= 2000 && o.yearFilm <= 2009).toList();
    print('   2000s (2000-2009): ${data2000s.length} records');
    if (data2000s.isNotEmpty) {
      final sample2000s = data2000s.take(3).toList();
      for (final sample in sample2000s) {
        print('     ${sample.yearFilm}: ${sample.canonCategory} - ${sample.name} (${sample.film})');
      }
    }
    
    // Check 2010s data  
    final data2010s = allData.where((o) => o.yearFilm >= 2010 && o.yearFilm <= 2019).toList();
    print('   2010s (2010-2019): ${data2010s.length} records');
    if (data2010s.isNotEmpty) {
      final sample2010s = data2010s.take(3).toList();
      for (final sample in sample2010s) {
        print('     ${sample.yearFilm}: ${sample.canonCategory} - ${sample.name} (${sample.film})');
      }
    }
    
    print('\n4. Testing decade calculation...');
    if (data2000s.isNotEmpty) {
      final testRecord = data2000s.first;
      final calculatedDecade = (testRecord.yearFilm ~/ 10) * 10;
      print('   Sample 2000s record: Year ${testRecord.yearFilm} -> Decade ${calculatedDecade}');
    }
    
    if (data2010s.isNotEmpty) {
      final testRecord = data2010s.first;
      final calculatedDecade = (testRecord.yearFilm ~/ 10) * 10;
      print('   Sample 2010s record: Year ${testRecord.yearFilm} -> Decade ${calculatedDecade}');
    }
    
    print('\n5. Available decades (simulating provider logic)...');
    final availableDecades = <int>{};
    for (final oscar in allData) {
      final decade = (oscar.yearFilm ~/ 10) * 10;
      availableDecades.add(decade);
    }
    final sortedAvailableDecades = availableDecades.toList()..sort();
    print('   Available decades: $sortedAvailableDecades');
    print('   Contains 2000s: ${sortedAvailableDecades.contains(2000)}');
    print('   Contains 2010s: ${sortedAvailableDecades.contains(2010)}');
    
    print('\n✅ Analysis complete!');
    
  } catch (e, stackTrace) {
    print('❌ Error: $e');
    print('Stack trace: $stackTrace');
  }
}