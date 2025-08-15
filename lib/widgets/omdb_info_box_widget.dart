import 'package:flutter/material.dart';
import 'package:oscars/models/oscar_winner.dart';
import 'package:oscars/services/omdb_service_extra.dart';

import '../design_system/design_system.dart';

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
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: OscarSpacing.paddingMd,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(child: OmdbInfoBox(oscar: oscar)),
            ),
            OscarSpacing.space4,
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OscarButton(
                  text: 'Close',
                  onPressed: () => Navigator.of(context).pop(),
                  variant: OscarButtonVariant.secondary,
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
          return OscarCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    if (info.rated != null && info.rated!.isNotEmpty)
                      OscarChip(
                        label: 'Rated: ${info.rated!}',
                        backgroundColor:
                            Theme.of(context).brightness == Brightness.light
                            ? Colors.orange.shade100
                            : Colors.orange.shade900,
                        size: OscarChipSize.small,
                      ),
                    if (info.runtime != null && info.runtime!.isNotEmpty)
                      OscarChip(
                        label: info.runtime!,
                        backgroundColor:
                            Theme.of(context).brightness == Brightness.light
                            ? Colors.blue.shade100
                            : Colors.blue.shade900,
                        size: OscarChipSize.small,
                      ),
                    if (info.genre != null && info.genre!.isNotEmpty)
                      OscarChip(
                        label: info.genre!.split(',').first,
                        backgroundColor:
                            Theme.of(context).brightness == Brightness.light
                            ? Colors.purple.shade100
                            : Colors.purple.shade900,
                        size: OscarChipSize.small,
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                if (info.released != null && info.released!.isNotEmpty)
                  Text(
                    'Released: ${info.released!}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                if (info.language != null && info.language!.isNotEmpty)
                  Text(
                    'Language: ${info.language!}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                if (info.country != null && info.country!.isNotEmpty)
                  Text(
                    'Country: ${info.country!}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                if (info.writer != null && info.writer!.isNotEmpty)
                  Text(
                    'Writer: ${info.writer!}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                if (info.plot != null && info.plot!.isNotEmpty)
                  Padding(
                    padding: OscarSpacing.paddingXs,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                      child: Text(
                        info.plot!,
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.normal,
                          color: Theme.of(context).colorScheme.onSurface,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                if (info.director != null && info.director!.isNotEmpty)
                  Text(
                    'Director: ${info.director!}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 16,
                    ),
                  ),
                if (info.actors != null && info.actors!.isNotEmpty)
                  Text(
                    'Actors: ${info.actors!}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                if (info.awards != null && info.awards!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.light
                            ? Colors.deepPurple.shade50
                            : Colors.deepPurple.shade900,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color:
                              Theme.of(context).brightness == Brightness.light
                              ? Colors.deepPurple.shade200
                              : Colors.deepPurple.shade700,
                        ),
                      ),
                      child: Text(
                        'Awards: ${info.awards!}',
                        style: TextStyle(
                          color:
                              Theme.of(context).brightness == Brightness.light
                              ? Colors.deepPurple.shade700
                              : Colors.deepPurple.shade400,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    if (info.imdbRating != null && info.imdbRating!.isNotEmpty)
                      OscarChip(
                        label: 'IMDb: ${info.imdbRating!}',
                        backgroundColor:
                            Theme.of(context).brightness == Brightness.light
                            ? Colors.amber.shade100
                            : Colors.amber.shade900,
                        size: OscarChipSize.small,
                        avatar: Icon(
                          Icons.star,
                          color:
                              Theme.of(context).brightness == Brightness.light
                              ? Colors.orange.shade800
                              : Colors.orange.shade400,
                          size: 16,
                        ),
                      ),
                    if (info.metascore != null && info.metascore!.isNotEmpty)
                      OscarChip(
                        label: 'Metascore: ${info.metascore!}',
                        backgroundColor:
                            Theme.of(context).brightness == Brightness.light
                            ? Colors.green.shade100
                            : Colors.green.shade900,
                        size: OscarChipSize.small,
                        avatar: Icon(
                          Icons.score,
                          color:
                              Theme.of(context).brightness == Brightness.light
                              ? Colors.green.shade800
                              : Colors.green.shade400,
                          size: 16,
                        ),
                      ),
                  ],
                ),
                if (info.imdbVotes != null && info.imdbVotes!.isNotEmpty)
                  Text(
                    'IMDb Votes: ${info.imdbVotes!}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                if (info.boxOffice != null && info.boxOffice!.isNotEmpty)
                  Text(
                    'Box Office: ${info.boxOffice!}',
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.green.shade700
                          : Colors.green.shade400,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                if (info.production != null && info.production!.isNotEmpty)
                  Text(
                    'Production: ${info.production!}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                if (info.website != null && info.website!.isNotEmpty)
                  Text(
                    'Website: ${info.website!}',
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.blue.shade700
                          : Colors.blue.shade400,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.underline,
                    ),
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
