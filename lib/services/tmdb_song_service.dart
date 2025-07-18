import 'dart:convert';
import 'package:http/http.dart' as http;

class TmdbSongService {
  static const String _apiKey = '4572c6689ec8341e580bdd81a126d08d';
  static const String _baseUrl = 'https://api.themoviedb.org/3/search/movie';

  static Future<List<String>> fetchSongsForMovie(String title, int year) async {
    final queryParameters = {
      'api_key': _apiKey,
      'query': title,
      'year': year.toString(),
    };
    final uri = Uri.parse(_baseUrl).replace(queryParameters: queryParameters);
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['results'] != null && data['results'].isNotEmpty) {
        final movieId = data['results'][0]['id'];
        // Now fetch movie details including soundtrack
        final detailsUrl = 'https://api.themoviedb.org/3/movie/$movieId?api_key=$_apiKey&append_to_response=credits';
        final detailsResponse = await http.get(Uri.parse(detailsUrl));
        if (detailsResponse.statusCode == 200) {
          final detailsData = json.decode(detailsResponse.body);
          // TMDb does not provide soundtrack directly, but you can parse credits for music department
          // This is a placeholder: you may need a third-party API for actual song names
          if (detailsData['credits'] != null && detailsData['credits']['crew'] != null) {
            final crew = detailsData['credits']['crew'] as List<dynamic>;
            final songs = crew
                .where((c) => c['department'] == 'Sound' || c['job'] == 'Original Music Composer')
                .map((c) => c['name'].toString())
                .toList();
            return songs;
          }
        }
      }
    }
    return [];
  }
}
