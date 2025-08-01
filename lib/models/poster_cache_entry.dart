import 'package:objectbox/objectbox.dart';

@Entity()
class PosterCacheEntry {
  @Id()
  int id = 0;

  /// Key format: '<film>_<year>'
  String cacheKey;
  String? posterUrl;
  DateTime updatedAt;

  PosterCacheEntry({
    required this.cacheKey,
    required this.posterUrl,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();
}

// Run the build runner to generate the necessary code
// dart run build_runner build
