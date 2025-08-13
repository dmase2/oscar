import '../models/oscar_winner.dart';

class OscarUtils {
  /// Determines if an Oscar is a special award
  static bool isSpecialAward(OscarWinner oscar) {
    return oscar.className?.toLowerCase() == 'special';
  }

  /// Gets the display title for the detail screen
  static String getDisplayTitle(OscarWinner oscar) {
    return isSpecialAward(oscar)
        ? 'Special Award - ${oscar.yearFilm}'
        : '${oscar.film} (${oscar.yearFilm})';
  }

  /// Gets the card title for the movie card
  static String getCardTitle(OscarWinner oscar) {
    return isSpecialAward(oscar) ? 'Special Award' : oscar.film;
  }

  /// Checks if the Oscar is for an original song
  static bool isOriginalSong(OscarWinner oscar) {
    return oscar.category.trim().toLowerCase() == 'music (original song)';
  }

  /// Checks if the Oscar should show song details
  static bool shouldShowSongDetail(OscarWinner oscar) {
    return isOriginalSong(oscar) && oscar.detail.isNotEmpty;
  }
}
