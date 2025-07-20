import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/oscar_winner.dart';
import '../services/poster_service.dart';

class PosterImageWidget extends StatefulWidget {
  final OscarWinner oscar;
  const PosterImageWidget({super.key, required this.oscar});

  @override
  State<PosterImageWidget> createState() => _PosterImageWidgetState();
}

class _PosterImageWidgetState extends State<PosterImageWidget> {
  static final Map<String, String?> _posterCache = {};
  String? _posterUrl;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _posterUrl = null;
    _fetchPoster();
  }

  @override
  void didUpdateWidget(covariant PosterImageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.oscar != widget.oscar) {
      _posterUrl = null;
      _fetchPoster();
    }
  }

  bool _isValidMovieTitle(String film) {
    if (film.trim().isEmpty) return false;
    final lower = film.trim().toLowerCase();
    final studios = [
      'fox',
      'paramount',
      'warner bros.',
      'metro-goldwyn-mayer',
      'universal',
      'columbia',
      'rko',
      'the caddo company',
      'the jazz singer',
      'chang',
      'the crowd',
      'the racket',
      'wings',
      'sunrise',
      '7th heaven',
      'the dove',
      'tempest',
      'sadie thompson',
      'street angel',
      'the last command',
      'the way of all flesh',
      'the patent leather kid',
      'the noose',
      'glorious betsy',
      'underworld',
      'the devil dancer',
      'the magic flame',
      'the private life of helen of troy',
      'speedy',
      'two arabian knights',
      'sorrell and son',
    ];
    if (studios.contains(lower)) return false;
    return RegExp(r'[a-zA-Z]').hasMatch(film);
  }

  Future<void> _fetchPoster() async {
    final cacheKey = '${widget.oscar.film}_${widget.oscar.yearFilm}';
    if (_posterCache.containsKey(cacheKey)) {
      setState(() {
        _posterUrl = _posterCache[cacheKey];
        _loading = false;
      });
      return;
    }
    setState(() => _loading = true);
    final film = widget.oscar.film;
    final year = widget.oscar.yearFilm;
    final imdbId = widget.oscar.filmId;
    String? posterUrl;
    if (_isValidMovieTitle(film)) {
      posterUrl = await PosterService.getPosterUrl(film, year, imdbId);
    } else {
      posterUrl = await PosterService.getPosterUrl('placeholder', 0, imdbId);
    }
    _posterCache[cacheKey] = posterUrl;
    if (mounted) {
      setState(() {
        _posterUrl = posterUrl;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_posterUrl != null) {
      return CachedNetworkImage(
        imageUrl: _posterUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) =>
            const Center(child: CircularProgressIndicator()),
        errorWidget: (context, url, error) => const Center(
          child: Icon(Icons.movie, size: 48, color: Colors.grey),
        ),
      );
    }
    return const Center(child: Icon(Icons.movie, size: 48, color: Colors.grey));
  }
}
