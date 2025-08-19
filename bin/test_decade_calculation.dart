/// Test decade calculation logic to identify the 2000s-2010s issue
void main() {
  print('=== Testing Decade Calculation Logic ===\n');
  
  // Test the decade calculation formula: (yearFilm ~/ 10) * 10
  final testYears = [1999, 2000, 2001, 2009, 2010, 2011, 2019, 2020, 2021];
  
  print('Current decade calculation: (yearFilm ~/ 10) * 10');
  print('Year -> Calculated Decade');
  print('------------------------');
  
  for (final year in testYears) {
    final decade = (year ~/ 10) * 10;
    print('$year -> ${decade}s');
  }
  
  print('\n🔍 Analysis:');
  print('• 2000-2009 -> 2000s decade ✓');
  print('• 2010-2019 -> 2010s decade ✓');
  print('• The decade calculation itself appears correct');
  
  print('\n🎯 Potential Issues:');
  print('1. Data might not exist for 2000s-2010s in the CSV');
  print('2. Year format in CSV might be different (e.g., "2000/01")');
  print('3. Filtering logic might have edge case bugs');
  print('4. Selected decade might not match available decades');
  
  print('\n📊 Let\'s check what should happen:');
  print('• Film from 2001 -> decade = (2001 ~/ 10) * 10 = 200 * 10 = 2000');
  print('• Film from 2015 -> decade = (2015 ~/ 10) * 10 = 201 * 10 = 2010');
  
  // Test the range filtering logic
  print('\n🔍 Range Filtering Test:');
  testRangeFiltering(2000); // 2000s
  testRangeFiltering(2010); // 2010s
}

void testRangeFiltering(int decade) {
  final endYear = decade + 9;
  print('Decade $decade -> Range: $decade to $endYear');
  
  // Test sample years
  final sampleYears = [decade - 1, decade, decade + 5, endYear, endYear + 1];
  print('  Year | In Range?');
  print('  -----|----------');
  
  for (final year in sampleYears) {
    final inRange = year >= decade && year <= endYear;
    print('  $year | ${inRange ? "✓" : "✗"}');
  }
  print('');
}