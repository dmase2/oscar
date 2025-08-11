import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;

class BoxOfficeMojoScraper {
  /// Scrapes Box Office Mojo for revenue data given an IMDb ID (e.g., tt0111161)
  /// Returns a map with keys: 'domestic', 'international', 'worldwide'
  static Future<Map<String, String>?> fetchRevenue(String imdbId) async {
    final url = 'https://www.boxofficemojo.com/title/$imdbId/';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3',
      },
    );
    if (response.statusCode != 200) {
      print('BoxOfficeMojoScraper: HTTP error ${response.statusCode}');
      print(
        'BoxOfficeMojoScraper: Response body: ${response.body.substring(0, response.body.length > 1000 ? 1000 : response.body.length)}',
      );
      return null;
    }
    final document = html_parser.parse(response.body);
    print(
      'BoxOfficeMojoScraper: HTML body (first 2000 chars): ${response.body.substring(0, response.body.length > 2000 ? 2000 : response.body.length)}',
    );
    final revenueMap = <String, String>{};
    // Try to find the revenue table
    final summaryTable = document.querySelector(
      '.a-section.a-spacing-none.mojo-summary-values',
    );
    if (summaryTable != null) {
      final rows = summaryTable.querySelectorAll('div');
      for (final row in rows) {
        final label = row
            .querySelector('.a-size-small')
            ?.text
            .trim()
            .toLowerCase();
        final value = row.querySelector('.a-size-medium')?.text.trim();
        if (label != null && value != null) {
          if (label.contains('domestic')) revenueMap['domestic'] = value;
          if (label.contains('international'))
            revenueMap['international'] = value;
          if (label.contains('worldwide')) revenueMap['worldwide'] = value;
        }
      }
    }
    return revenueMap.isNotEmpty ? revenueMap : null;
  }
}
