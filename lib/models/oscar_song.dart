class OscarSongInfo {
  final int year;
  final String songTitle;
  final String movieTitle;
  final String musicAuthor;
  final String lyricAuthor;
  final String imdbId;
  final String tmdbId;

  OscarSongInfo({
    required this.year,
    required this.songTitle,
    required this.movieTitle,
    required this.musicAuthor,
    required this.lyricAuthor,
    required this.imdbId,
    required this.tmdbId,
  });

  factory OscarSongInfo.fromCsv(List<dynamic> row) {
    return OscarSongInfo(
      year: int.tryParse(row[0].toString()) ?? 0,
      songTitle: row[1].toString(),
      movieTitle: row[2].toString(),
      musicAuthor: row[3].toString(),
      lyricAuthor: row[4].toString(),
      imdbId: row[5].toString(),
      tmdbId: row[6].toString(),
    );
  }
}
