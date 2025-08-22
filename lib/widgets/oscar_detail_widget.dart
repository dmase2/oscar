import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:oscars/models/oscar_winner.dart';
import 'package:oscars/services/omdb_service.dart';
import 'package:oscars/utils/nominee_parser.dart';
import 'package:oscars/utils/oscar_utils.dart';
import 'package:oscars/widgets/nominees_section.dart';

import '../providers/boxoffice_providers.dart';
import '../screens/oscar_person_lookup_screen.dart';

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
    // Parse nominees using the utility class
    final nominees = NomineeParser.parseNominees(
      widget.oscar.nominee,
      widget.oscar.nomineeId,
    );

    // Currency formatter
    final moneyFormat = NumberFormat.simpleCurrency(decimalDigits: 0);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: OscarUtils.isSpecialAward(widget.oscar)
                ? Center(
                    child: Text(
                      'Special Award - ${widget.oscar.yearFilm}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.normal,
                        fontSize: 22,
                      ),
                    ),
                  )
                : Center(
                    child: Text(
                      '${widget.oscar.film} (${widget.oscar.yearFilm})',
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium?.copyWith(fontSize: 22),
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
                  const SizedBox(height: 4),
                  if (OscarUtils.shouldShowSongDetail(widget.oscar))
                    _buildDetailRow(context, 'Song', widget.oscar.detail),

                  if (!OscarUtils.isSpecialAward(widget.oscar))
                    NomineesSection(
                      nominees: nominees,
                      onNomineePressed: (name, id) =>
                          _showNomineeNominationsDialog(context, name, id),
                    ),

                  // Show role for acting categories
                  if (_isActingCategory(widget.oscar.className) &&
                      widget.oscar.detail.isNotEmpty)
                    _buildDetailRow(context, 'Role', widget.oscar.detail),

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
                  if (!OscarUtils.isSpecialAward(widget.oscar))
                    FutureBuilder<int?>(
                      future: widget.oscar.filmId.isNotEmpty
                          ? OmdbService.fetchRottenTomatoesScore(
                              widget.oscar.filmId,
                            )
                          : null,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 120,
                                  child: Text(
                                    'Rotten Tomatoes:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface.withOpacity(0.6),
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
                  // Box Office info from BoxOfficeEntry store
                  Consumer(
                    builder: (context, ref, _) {
                      return ref
                          .watch(allBoxOfficeEntriesProvider)
                          .when(
                            data: (entries) {
                              // Extract numeric IMDb ID
                              final idStr = widget.oscar.filmId.replaceAll(
                                RegExp(r'[^0-9]'),
                                '',
                              );
                              final imdbId = int.tryParse(idStr);
                              if (imdbId == null) {
                                return const SizedBox.shrink();
                              }
                              // Filter matching entries
                              final matches = entries
                                  .where((e) => e.id == imdbId)
                                  .toList();
                              if (matches.isEmpty) {
                                return const SizedBox.shrink();
                              }
                              // If multiple entries exist (e.g., limited vs full release), pick the one with highest worldwide gross
                              final match = matches.reduce(
                                (current, next) =>
                                    next.worldwide > current.worldwide
                                    ? next
                                    : current,
                              );
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildDetailRow(
                                    context,
                                    'Domestic',
                                    moneyFormat.format(match.domestic),
                                  ),
                                  _buildDetailRow(
                                    context,
                                    'International',
                                    moneyFormat.format(match.international),
                                  ),
                                  _buildDetailRow(
                                    context,
                                    'Worldwide',
                                    moneyFormat.format(match.worldwide),
                                  ),
                                ],
                              );
                            },
                            loading: () => const SizedBox.shrink(),
                            error: (_, __) => const SizedBox.shrink(),
                          );
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
    if (nomineeId.isEmpty) return;

    // Navigate to the Oscar Person Lookup Screen with the nominee ID
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            OscarPersonLookupScreen(initialNomineeId: nomineeId),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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

  bool _isActingCategory(String? className) {
    if (className == null) return false;
    return className.toLowerCase() == 'acting';
  }
}
