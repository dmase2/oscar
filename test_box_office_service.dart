import 'lib/services/box_office_service.dart';
import 'lib/services/database_service.dart';

void main() async {
  // Mock the rootBundle for testing
  const String testCsvData =
      '''Year,Title,Domestic,International,Worldwide,ImdbID,URL
1977,Star Wars: Episode IV - A New Hope,\$307,263,857,\$0,\$307,263,857,tt0076759,https://www.boxofficemojo.com/release/rl2759034369/?ref_=bo_yld_table_1
1977,Close Encounters of the Third Kind,\$116,395,460,\$781,\$116,396,241,tt0075860,https://www.boxofficemojo.com/release/rl340428289/?ref_=bo_yld_table_9
1977,Saturday Night Fever,\$94,213,184,\$1,152,\$94,214,336,tt0076666,https://www.boxofficemojo.com/release/rl2926544385/?ref_=bo_yld_table_8''';

  // Initialize DatabaseService
  await DatabaseService.instance.initialize();

  // Clear existing data
  await BoxOfficeService.instance.clearBoxOfficeData();

  // Force reload from CSV
  await BoxOfficeService.instance.reloadBoxOfficeData();

  // Test data retrieval
  final entries = BoxOfficeService.instance.getAllBoxOfficeEntries();
  print('Total entries loaded: ${entries.length}');

  // Check first few entries
  for (int i = 0; i < 3 && i < entries.length; i++) {
    final entry = entries[i];
    print('\nEntry $i:');
    print('  ID: ${entry.id}');
    print('  Title: ${entry.title}');
    print('  Domestic: ${entry.domestic}');
    print('  International: ${entry.international}');
    print('  Worldwide: ${entry.worldwide}');
  }

  // Test specific lookup
  final starWarsEntry = BoxOfficeService.instance.getBoxOfficeEntryById(76759);
  if (starWarsEntry != null) {
    print('\nStar Wars Entry:');
    print('  Title: ${starWarsEntry.title}');
    print('  Domestic: ${starWarsEntry.domestic}');
    print('  International: ${starWarsEntry.international}');
    print('  Worldwide: ${starWarsEntry.worldwide}');
  } else {
    print('\nStar Wars entry not found');
  }
}
