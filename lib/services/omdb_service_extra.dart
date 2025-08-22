import 'dart:convert';

import 'package:http/http.dart' as http;

class OmdbExtraInfo {
  final String? title;
  final String? year;
  final String? rated;
  final String? released;
  final String? runtime;
  final String? genre;
  final String? director;
  final String? writer;
  final String? actors;
  final String? plot;
  final String? language;
  final String? country;
  final String? awards;
  final String? poster;
  final List<dynamic>? ratings;
  final String? metascore;
  final String? imdbRating;
  final String? imdbVotes;
  final String? imdbID;
  final String? type;
  final String? dvd;
  final String? boxOffice;
  final String? production;
  final String? website;
  final String? response;

  OmdbExtraInfo({
    this.title,
    this.year,
    this.rated,
    this.released,
    this.runtime,
    this.genre,
    this.director,
    this.writer,
    this.actors,
    this.plot,
    this.language,
    this.country,
    this.awards,
    this.poster,
    this.ratings,
    this.metascore,
    this.imdbRating,
    this.imdbVotes,
    this.imdbID,
    this.type,
    this.dvd,
    this.boxOffice,
    this.production,
    this.website,
    this.response,
  });

  factory OmdbExtraInfo.fromJson(Map<String, dynamic> json) {
    return OmdbExtraInfo(
      title: json['Title'],
      year: json['Year'],
      rated: json['Rated'],
      released: json['Released'],
      runtime: json['Runtime'],
      genre: json['Genre'],
      director: json['Director'],
      writer: json['Writer'],
      actors: json['Actors'],
      plot: json['Plot'],
      language: json['Language'],
      country: json['Country'],
      awards: json['Awards'],
      poster: json['Poster'],
      ratings: json['Ratings'],
      metascore: json['Metascore'],
      imdbRating: json['imdbRating'],
      imdbVotes: json['imdbVotes'],
      imdbID: json['imdbID'],
      type: json['Type'],
      dvd: json['DVD'],
      boxOffice: json['BoxOffice'],
      production: json['Production'],
      website: json['Website'],
      response: json['Response'],
    );
  }
}

class OmdbServiceExtra {
  static Future<OmdbExtraInfo?> fetchExtraInfoByTitle(
    String title,
    int year,
  ) async {
    // Only include the year parameter when a valid year (>0) is provided.
    final qp = <String, String>{'apikey': _apiKey, 't': title};
    if (year > 0) qp['y'] = year.toString();
    final uri = Uri.parse(_baseUrl).replace(queryParameters: qp);
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return OmdbExtraInfo.fromJson(data);
    }
    return null;
  }

  static const String _apiKey = 'b925d287';
  static const String _baseUrl = 'http://www.omdbapi.com/';

  static Future<OmdbExtraInfo?> fetchExtraInfo(String imdbId) async {
    final uri = Uri.parse(
      _baseUrl,
    ).replace(queryParameters: {'apikey': _apiKey, 'i': imdbId});
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return OmdbExtraInfo.fromJson(data);
    }
    return null;
  }
}
