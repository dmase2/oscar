import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:oscars/models/oscar_song.dart';

class OscarSongService {
  static List<OscarSongInfo>? _cache;

  static Future<List<OscarSongInfo>> loadSongs() async {
    if (_cache != null) return _cache!;
    final csvString = await rootBundle.loadString(
      'assets/data/oscar_songs.csv',
    );
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
