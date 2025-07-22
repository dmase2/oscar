import 'package:flutter/material.dart';
import 'package:oscars/models/oscar_winner.dart';
import 'package:oscars/services/omdb_service_extra.dart';

class OmdbInfoBox extends StatefulWidget {
  final OscarWinner oscar;
  const OmdbInfoBox({super.key, required this.oscar});

  @override
  State<OmdbInfoBox> createState() => _OmdbInfoBoxState();
}

class _OmdbInfoBoxState extends State<OmdbInfoBox> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => expanded = !expanded),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Movie Details',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Icon(expanded ? Icons.expand_less : Icons.expand_more),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: FutureBuilder<OmdbExtraInfo?>(
            future: () async {
              if (widget.oscar.filmId.isNotEmpty) {
                return await OmdbServiceExtra.fetchExtraInfo(
                  widget.oscar.filmId,
                );
              } else {
                // Fallback: search OMDb by title and year
                final info = await OmdbServiceExtra.fetchExtraInfoByTitle(
                  widget.oscar.film,
                  widget.oscar.yearFilm,
                );
                return info;
              }
            }(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasData && snapshot.data != null) {
                final info = snapshot.data!;
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (info.rated != null && info.rated!.isNotEmpty)
                            Chip(label: Text('Rated: ${info.rated!}')),
                          if (info.runtime != null && info.runtime!.isNotEmpty)
                            Chip(label: Text(info.runtime!)),
                          if (info.genre != null && info.genre!.isNotEmpty)
                            Chip(label: Text(info.genre!.split(',').first)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (info.plot != null && info.plot!.isNotEmpty)
                        Text(
                          info.plot!,
                          style: const TextStyle(
                            fontSize: 15,
                            fontStyle: FontStyle.italic,
                            color: Colors.black87,
                          ),
                        ),
                      const SizedBox(height: 8),
                      if (info.director != null && info.director!.isNotEmpty)
                        Text(
                          'Director: ${info.director!}',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      if (info.actors != null && info.actors!.isNotEmpty)
                        Text(
                          'Actors: ${info.actors!}',
                          style: const TextStyle(color: Colors.black54),
                        ),
                      if (info.awards != null && info.awards!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Awards: ${info.awards!}',
                            style: const TextStyle(color: Colors.deepPurple),
                          ),
                        ),
                      Row(
                        children: [
                          if (info.imdbRating != null &&
                              info.imdbRating!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(right: 12.0),
                              child: Chip(
                                avatar: const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 18,
                                ),
                                label: Text('IMDb: ${info.imdbRating!}'),
                              ),
                            ),
                          if (info.metascore != null &&
                              info.metascore!.isNotEmpty)
                            Chip(
                              avatar: const Icon(
                                Icons.score,
                                color: Colors.green,
                                size: 18,
                              ),
                              label: Text('Metascore: ${info.metascore!}'),
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          crossFadeState: expanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
        ),
      ],
    );
  }
}
