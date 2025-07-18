import 'tmdb_service.dart';

class PosterService {
  static Future<String?> getPosterUrl(String movieTitle, int year) async {
    // Try TMDb API first
    final tmdbPoster = await TmdbService.fetchPosterUrl(movieTitle, year);
    if (tmdbPoster != null) {
      return tmdbPoster;
    }
    // Fallback to placeholder
    return _getPlaceholderPosterUrl(movieTitle);
  }

  static String _getPlaceholderPosterUrl(String movieTitle) {
    final hash = movieTitle.hashCode.abs();
    final seed = hash % 1000;
    return 'https://picsum.photos/seed/$seed/300/450';
  }
}
