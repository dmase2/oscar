import 'package:flutter/material.dart';
import 'package:oscars/models/oscar_winner.dart';
import 'package:oscars/services/omdb_service_extra.dart';

// Popup dialog version
Future<void> showOmdbInfoDialog(BuildContext context, OscarWinner oscar) async {
  return showDialog(
    context: context,
    builder: (context) => OmdbInfoDialog(oscar: oscar),
  );
}

class OmdbInfoDialog extends StatelessWidget {
  final OscarWinner oscar;
  const OmdbInfoDialog({super.key, required this.oscar});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SingleChildScrollView(child: OmdbInfoBox(oscar: oscar)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class OmdbInfoBox extends StatefulWidget {
  final OscarWinner oscar;
  const OmdbInfoBox({super.key, required this.oscar});

  @override
  State<OmdbInfoBox> createState() => _OmdbInfoBoxState();
}

class _OmdbInfoBoxState extends State<OmdbInfoBox> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<OmdbExtraInfo?>(
      future: () async {
        if (widget.oscar.filmId.isNotEmpty) {
          return await OmdbServiceExtra.fetchExtraInfo(widget.oscar.filmId);
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
              color: Theme.of(context).colorScheme.surface,
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
                if (info.released != null && info.released!.isNotEmpty)
                  Text(
                    'Released: ${info.released!}',
                    style: const TextStyle(color: Colors.black87),
                  ),
                if (info.language != null && info.language!.isNotEmpty)
                  Text(
                    'Language: ${info.language!}',
                    style: const TextStyle(color: Colors.black87),
                  ),
                if (info.country != null && info.country!.isNotEmpty)
                  Text(
                    'Country: ${info.country!}',
                    style: const TextStyle(color: Colors.black87),
                  ),
                if (info.writer != null && info.writer!.isNotEmpty)
                  Text(
                    'Writer: ${info.writer!}',
                    style: const TextStyle(color: Colors.black87),
                  ),
                if (info.plot != null && info.plot!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      info.plot!,
                      style: const TextStyle(
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                        color: Colors.black87,
                      ),
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
                    if (info.imdbRating != null && info.imdbRating!.isNotEmpty)
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
                    if (info.metascore != null && info.metascore!.isNotEmpty)
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
                if (info.imdbVotes != null && info.imdbVotes!.isNotEmpty)
                  Text(
                    'IMDb Votes: ${info.imdbVotes!}',
                    style: const TextStyle(color: Colors.black87),
                  ),
                if (info.boxOffice != null && info.boxOffice!.isNotEmpty)
                  Text(
                    'Box Office: ${info.boxOffice!}',
                    style: const TextStyle(color: Colors.black87),
                  ),
                if (info.production != null && info.production!.isNotEmpty)
                  Text(
                    'Production: ${info.production!}',
                    style: const TextStyle(color: Colors.black87),
                  ),
                if (info.website != null && info.website!.isNotEmpty)
                  Text(
                    'Website: ${info.website!}',
                    style: const TextStyle(color: Colors.blue),
                  ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
