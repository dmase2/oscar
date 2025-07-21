import 'tmdb_service.dart';

class PosterService {
  static Future<String?> getPosterUrl(
    String movieTitle,
    int year,
    String imdbId,
  ) async {
    // Try TMDb API first, with OMDb fallback
    final posterUrl = await TmdbService.fetchPosterUrl(
      movieTitle,
      year,
      imdbId: imdbId,
    );
    if (posterUrl != null) {
      return posterUrl;
    }
    // Fallback to local Oscar icon asset
    return 'assets/images/image_not_found.jpeg';
  }

  static String _getPlaceholderPosterUrl(String movieTitle) {
    final hash = movieTitle.hashCode.abs();
    final seed = hash % 1000;
    return 'https://picsum.photos/seed/$seed/300/450';
  }
}
