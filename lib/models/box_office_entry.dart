import 'package:objectbox/objectbox.dart';

/// Represents a Box Office entry imported from CSV.
/// Uses the numeric part of the IMDb ID as the primary key.
@Entity()
class BoxOfficeEntry {
  /// Primary key: parsed numeric part of IMDb ID (e.g., 'tt1234567' -> 1234567)
  @Id(assignable: true)
  int id;

  /// Movie title
  String title;

  /// Domestic box office in USD cents or dollars
  int domestic;

  /// International box office in USD cents or dollars
  int international;

  /// Worldwide box office in USD cents or dollars
  int worldwide;

  /// Original URL from Box Office Mojo
  String url;

  BoxOfficeEntry({
    required this.id,
    required this.title,
    required this.domestic,
    required this.international,
    required this.worldwide,
    required this.url,
  });
}
