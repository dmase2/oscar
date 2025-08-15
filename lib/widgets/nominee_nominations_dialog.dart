import 'package:flutter/material.dart';
import 'package:oscars/design_system/components/oscar_button.dart';
import 'package:oscars/design_system/tokens.dart';
import 'package:oscars/services/database_service.dart';
import 'package:oscars/services/nominee_nominations_service.dart';
import 'package:oscars/widgets/summary_chip_widget.dart';

class NomineeNominationsDialog extends StatefulWidget {
  final String nominee;
  final String nomineeId;
  final String? categoryFilter; // Add category filter

  const NomineeNominationsDialog({
    super.key,
    required this.nominee,
    required this.nomineeId,
    this.categoryFilter, // Optional category filter
  });

  @override
  State<NomineeNominationsDialog> createState() =>
      _NomineeNominationsDialogState();
}

class _NomineeNominationsDialogState extends State<NomineeNominationsDialog> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dbService = DatabaseService.instance;
    final allWinners = dbService.getAllOscarWinners();
    final stats = NomineeNominationsService.getNomineeNominations(
      allWinners,
      widget.nomineeId,
    );
    final nominations = stats.nominations;
    final wins = stats.wins;
    final specialAwards = stats.specialAwards;
    final movies = allWinners
        .where(
          (w) => w.nomineeId
              .split('|')
              .map((n) => n.trim())
              .contains(widget.nomineeId),
        )
        .where((w) {
          if (widget.categoryFilter == null) return true;
          if (widget.categoryFilter == 'ALL_ACTING') {
            // Special case: filter to acting categories only
            return w.className?.toLowerCase() == 'acting';
          }
          return w.canonCategory == widget.categoryFilter;
        })
        .toList();

    // Calculate stats for the filtered movies
    int displayNominations, displayWins, displaySpecialAwards;
    if (widget.categoryFilter != null) {
      // For specific category, count filtered movies
      final regularNominations = movies
          .where((m) => m.className?.toLowerCase() != 'special')
          .toList();
      final specialAwardsList = movies
          .where((m) => m.className?.toLowerCase() == 'special')
          .toList();

      final nominationPairs = <String>{};
      final winPairs = <String>{};
      for (final movie in regularNominations) {
        final key = '${movie.canonCategory}|${movie.yearFilm}|${movie.filmId}';
        nominationPairs.add(key);
        if (movie.winner) winPairs.add(key);
      }

      displayNominations = nominationPairs.length;
      displayWins = winPairs.length;
      displaySpecialAwards = specialAwardsList.length;
    } else {
      // Show overall stats for all categories
      displayNominations = nominations;
      displayWins = wins;
      displaySpecialAwards = specialAwards;
    }
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                widget.categoryFilter != null
                    ? widget.categoryFilter == 'ALL_ACTING'
                          ? 'Acting Nominations for ${widget.nominee}'
                          : '${widget.categoryFilter} Nominations for ${widget.nominee}'
                    : 'All Nominations for ${widget.nominee}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,

              children: [
                SummaryChip(
                  label: 'Noms',
                  count: displayNominations,
                  color: OscarDesignTokens.info,
                ),
                SummaryChip(
                  label: 'Wins',
                  count: displayWins,
                  color: OscarDesignTokens.oscarGoldDark,
                ),
                SummaryChip(
                  label: 'Special',
                  count: displaySpecialAwards,
                  color: OscarDesignTokens.special,
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(),
            Expanded(
              child: Scrollbar(
                thumbVisibility: true,
                controller: _scrollController,
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: movies.length,
                  itemBuilder: (context, idx) {
                    final m = movies[idx];
                    return ListTile(
                      title: Text(m.film, overflow: TextOverflow.ellipsis),
                      subtitle: Text(
                        '${m.yearFilm} - ${m.category} ${m.winner ? '🏆' : ''}',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OscarButton(
                  variant: OscarButtonVariant.secondary,
                  onPressed: () => Navigator.pop(context),
                  text: 'Close',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
