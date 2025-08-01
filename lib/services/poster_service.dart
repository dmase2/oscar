import '../models/poster_cache_entry.dart';
import '../objectbox.g.dart';
import 'database_service.dart';
import 'tmdb_service.dart';

class PosterService {
  static Future<String?> getPosterUrl(
    String movieTitle,
    int year,
    String imdbId,
  ) async {
    final cacheKey = '${movieTitle}_$year';
    final store = DatabaseService.instance.store;
    final posterBox = store.box<PosterCacheEntry>();
    // Check ObjectBox cache first
    final query = posterBox
        .query(PosterCacheEntry_.cacheKey.equals(cacheKey))
        .build();
    final cached = query.findFirst();
    query.close();
    if (cached != null &&
        cached.posterUrl != null &&
        cached.posterUrl!.isNotEmpty) {
      return cached.posterUrl;
    }
    // Try TMDb API first, with OMDb fallback
    final posterUrl = await TmdbService.fetchPosterUrl(
      movieTitle,
      year,
      imdbId: imdbId,
    );
    // Save to ObjectBox cache
    posterBox.put(PosterCacheEntry(cacheKey: cacheKey, posterUrl: posterUrl));
    if (posterUrl != null) {
      return posterUrl;
    }
    // Fallback to local Oscar icon asset
    return 'assets/images/image_not_found.jpeg';
  }
}
