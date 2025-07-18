import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

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

class OscarSongService {
  static List<OscarSongInfo>? _cache;

  static Future<List<OscarSongInfo>> loadSongs() async {
    if (_cache != null) return _cache!;
    final csvString = await rootBundle.loadString('assets/data/oscar_songs.csv');
    final lines = LineSplitter.split(csvString).toList();
    final rows = lines.skip(1).map((line) => line.split(',')).toList();
    _cache = rows.map((row) => OscarSongInfo.fromCsv(row)).toList();
    return _cache!;
  }

  static Future<OscarSongInfo?> getSongByTmdbId(String tmdbId) async {
    final songs = await loadSongs();
    try {
      return songs.firstWhere((song) => song.tmdbId == tmdbId);
    } catch (e) {
      return null;
    }
  }
}
