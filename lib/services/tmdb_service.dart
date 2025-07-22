import 'dart:convert';

import 'package:http/http.dart' as http;

import 'omdb_service.dart';

class TmdbService {
  static Future<int?> fetchTotalBoxOffice(String title, int year) async {
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
        final detailsUrl =
            'https://api.themoviedb.org/3/movie/$movieId?api_key=$_apiKey';
        final detailsResponse = await http.get(Uri.parse(detailsUrl));
        if (detailsResponse.statusCode == 200) {
          final detailsData = json.decode(detailsResponse.body);
          if (detailsData['revenue'] != null) {
            return detailsData['revenue'] as int;
          }
        }
      }
    }
    return null;
  }

  static const String _apiKey =
      '4572c6689ec8341e580bdd81a126d08d'; // Replace with your TMDb API key
  static const String _baseUrl = 'https://api.themoviedb.org/3/search/movie';
  static const String _imageBaseUrl = 'https://image.tmdb.org/t/p/w500';

  static Future<String?> fetchPosterUrl(
    String title,
    int year, {
    String? imdbId,
  }) async {
    final queryParameters = {
      'api_key': _apiKey,
      'query': title,
      'year': year.toString(),
    };
    final uri = Uri.parse(_baseUrl).replace(queryParameters: queryParameters);
    try {
      print('TMDb REQUEST: $uri');
      final response = await http.get(uri);
      print('TMDb RESPONSE (${response.statusCode}): ${response.body}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          // Try to find an exact match for title and year
          final results = data['results'] as List;
          final normalizedTitle = title.trim().toLowerCase();
          final exactMatch = results.firstWhere((movie) {
            final movieTitle = (movie['title'] ?? '')
                .toString()
                .trim()
                .toLowerCase();
            final releaseDate = (movie['release_date'] ?? '').toString();
            final movieYear = releaseDate.isNotEmpty
                ? int.tryParse(releaseDate.substring(0, 4))
                : null;
            return movieTitle == normalizedTitle && movieYear == year;
          }, orElse: () => null);
          final movie = exactMatch ?? results[0];
          final posterPath = movie['poster_path'];
          if (posterPath != null) {
            final posterUrl = '$_imageBaseUrl$posterPath';
            print('TMDb POSTER URL: $posterUrl');
            return posterUrl;
          } else {
            print(
              'TMDb NO POSTER PATH for "$title" ($year) in matched movie: ${movie['title']} (${movie['release_date']})',
            );
          }
        } else {
          print('TMDb NO RESULTS for "$title" ($year)');
        }
      } else {
        print('TMDb ERROR: HTTP ${response.statusCode}');
      }
    } catch (e, st) {
      print('TMDb HTTP Exception: $e\n$st');
    }
    // Try OMDb as fallback
    if (imdbId != null && imdbId.isNotEmpty) {
      try {
        print('Trying OMDb for poster...');
        final omdbPoster = await OmdbService.fetchPosterUrl(imdbId);
        if (omdbPoster != null) {
          print('OMDb POSTER URL: $omdbPoster');
          return omdbPoster;
        }
      } catch (e, st) {
        print('OMDb HTTP Exception: $e\n$st');
      }
    }
    return null;
  }
}
