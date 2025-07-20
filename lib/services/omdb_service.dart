import 'dart:convert';

import 'package:http/http.dart' as http;

class OmdbService {
  /// Fetches poster URL for a movie using its IMDb ID.
  static Future<String?> fetchPosterUrl(String imdbId) async {
    final uri = Uri.parse(_baseUrl).replace(queryParameters: {'apikey': _apiKey, 'i': imdbId});
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final posterUrl = data['Poster'];
      if (posterUrl != null && posterUrl != 'N/A') {
        return posterUrl as String;
      }
    }
    return null;
  }
  static const String _apiKey = 'b925d287'; // Replace with your OMDb API key
  static const String _baseUrl = 'http://www.omdbapi.com/';

  /// Fetches Rotten Tomatoes score for a movie using its IMDb ID.
  static Future<int?> fetchRottenTomatoesScore(String imdbId) async {
    final uri = Uri.parse(
      _baseUrl,
    ).replace(queryParameters: {'apikey': _apiKey, 'i': imdbId});
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['Ratings'] != null) {
        for (final rating in data['Ratings']) {
          if (rating['Source'] == 'Rotten Tomatoes') {
            final value = rating['Value'] as String;
            // Value is like "87%"
            final percent = int.tryParse(value.replaceAll('%', ''));
            return percent;
          }
        }
      }
    }
    return null;
  }
}
