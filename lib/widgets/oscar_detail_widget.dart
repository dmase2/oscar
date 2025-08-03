import 'package:flutter/material.dart';
import 'package:oscars/models/oscar_winner.dart';
import 'package:oscars/services/omdb_service.dart';
import 'package:oscars/widgets/nominee_nominations_dialog.dart';

class OscarDetailSection extends StatefulWidget {
  final OscarWinner oscar;
  const OscarDetailSection({super.key, required this.oscar});

  @override
  State<OscarDetailSection> createState() => _OscarDetailSectionState();
}

class _OscarDetailSectionState extends State<OscarDetailSection> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    // Parse nominees and nomineeIds into a list of maps
    final nomineeNames = widget.oscar.nominee
        .split('|')
        .map((s) => s.trim())
        .toList();
    final nomineeIds = widget.oscar.nomineeId
        .split('|')
        .map((s) => s.trim())
        .toList();
    final nominees = <Map<String, String>>[];
    for (int i = 0; i < nomineeNames.length; i++) {
      nominees.add({
        'name': nomineeNames[i],
        'id': i < nomineeIds.length ? nomineeIds[i] : '',
      });
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(
              '${widget.oscar.film} (${widget.oscar.yearFilm})',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            trailing: IconButton(
              icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () => setState(() => _expanded = !_expanded),
            ),
            onTap: () => setState(() => _expanded = !_expanded),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  if (widget.oscar.category.trim().toLowerCase() ==
                          'music (original song)' &&
                      widget.oscar.detail.isNotEmpty)
                    _buildDetailRow(context, 'Song', widget.oscar.detail),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 120,
                          child: Text(
                            'Nominee(s):',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              for (final nominee in nominees)
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          nominee['name'] ?? '',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(fontSize: 16),
                                        ),
                                        const SizedBox(width: 2),
                                        OutlinedButton(
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 0,
                                            ),
                                            minimumSize: const Size(0, 24),
                                            tapTargetSize: MaterialTapTargetSize
                                                .shrinkWrap,
                                          ),
                                          onPressed:
                                              nominee['id'] != null &&
                                                  nominee['id']!.isNotEmpty
                                              ? () =>
                                                    _showNomineeNominationsDialog(
                                                      context,
                                                      nominee['name']!,
                                                      nominee['id']!,
                                                    )
                                              : null,
                                          child: const Text(
                                            'Nominations',
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  _buildDetailRow(context, 'Category', widget.oscar.category),
                  if (widget.oscar.category != widget.oscar.canonCategory)
                    _buildDetailRow(
                      context,
                      'Canon Category',
                      widget.oscar.canonCategory,
                    ),

                  _buildDetailRow(
                    context,
                    'Winner',
                    widget.oscar.winner ? 'Yes' : 'No',
                  ),
                  FutureBuilder<int?>(
                    future: widget.oscar.filmId.isNotEmpty
                        ? OmdbService.fetchRottenTomatoesScore(
                            widget.oscar.filmId,
                          )
                        : null,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 120,
                                child: Text(
                                  'Rotten Tomatoes:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              CircularProgressIndicator(),
                            ],
                          ),
                        );
                      } else if (snapshot.hasData && snapshot.data != null) {
                        final score = snapshot.data!;
                        String emoji = score >= 60 ? '🍅' : '🤢';
                        return _buildDetailRow(
                          context,
                          'Rotten Tomatoes',
                          '$emoji $score%',
                        );
                      } else {
                        return _buildDetailRow(
                          context,
                          'Rotten Tomatoes',
                          '🟦 N/A',
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }

  void _showNomineeNominationsDialog(
    BuildContext context,
    String nominee,
    String nomineeId,
  ) {
    if (widget.oscar.nomineeId.isEmpty) return;
    showDialog(
      context: context,
      builder: (context) =>
          NomineeNominationsDialog(nominee: nominee, nomineeId: nomineeId),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
