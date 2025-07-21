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
    String? posterUrl = await PosterService.getPosterUrl(film, year, imdbId);
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
    Widget noPosterWidget(String assetPath) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Image.asset(
              assetPath,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No poster found',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      );
    }
    if (_posterUrl != null) {
      if (_posterUrl!.startsWith('assets/')) {
        return noPosterWidget(_posterUrl!);
      } else {
        return CachedNetworkImage(
          imageUrl: _posterUrl!,
          fit: BoxFit.cover,
          placeholder: (context, url) =>
              const Center(child: CircularProgressIndicator()),
          errorWidget: (context, url, error) => noPosterWidget('assets/images/image_not_found.jpeg'),
        );
      }
    }
    return noPosterWidget('assets/images/image_not_found.jpeg');
  }
}
