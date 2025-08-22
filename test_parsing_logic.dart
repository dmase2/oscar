void main() async {
  // Test the exact parsing logic from BoxOfficeService
  final testRow = [
    '1977',
    'Saturday Night Fever',
    '\$94,213,184',
    '\$1,152',
    '\$94,214,336',
    'tt0076666',
    'https://www.boxofficemojo.com/release/rl2926544385/?ref_=bo_yld_table_8',
  ];

  print('Testing CSV parsing logic...');
  print('Test row: $testRow');
  print('Row length: ${testRow.length}');

  if (testRow.length >= 7) {
    final title = testRow[1].toString();
    print('Title: $title');

    // Strip non-digits from currency strings
    final domesticStr = testRow[2].toString().replaceAll(RegExp(r'[^0-9]'), '');
    final domestic = domesticStr.isEmpty ? 0 : int.parse(domesticStr);
    print(
      'Domestic: raw="${testRow[2]}" -> cleaned="$domesticStr" -> parsed=$domestic',
    );

    final internationalStr = testRow[3].toString().replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );
    final international = internationalStr.isEmpty
        ? 0
        : int.parse(internationalStr);
    print(
      'International: raw="${testRow[3]}" -> cleaned="$internationalStr" -> parsed=$international',
    );

    final worldwideStr = testRow[4].toString().replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );
    final worldwide = worldwideStr.isEmpty ? 0 : int.parse(worldwideStr);
    print(
      'Worldwide: raw="${testRow[4]}" -> cleaned="$worldwideStr" -> parsed=$worldwide',
    );

    // Extract numeric part of IMDb ID (e.g., 'tt1234567' -> '1234567')
    final imdbIdStr = testRow[5].toString().replaceAll(RegExp(r'[^0-9]'), '');
    print(
      'IMDb ID: raw="${testRow[5]}" -> cleaned="$imdbIdStr" -> parsed=${int.parse(imdbIdStr)}',
    );

    print('\nWould create BoxOfficeEntry:');
    print('  id: ${int.parse(imdbIdStr)}');
    print('  title: $title');
    print('  domestic: $domestic');
    print('  international: $international');
    print('  worldwide: $worldwide');
    print('  url: ${testRow[6]}');
  } else {
    print('Row too short!');
  }
}
