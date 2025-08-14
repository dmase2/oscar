import 'package:flutter/material.dart';
import 'package:oscars/design_system/components/oscar_button.dart';
import 'package:oscars/design_system/tokens.dart';
import 'package:oscars/services/database_service.dart';
import 'package:oscars/services/nominee_nominations_service.dart';
import 'package:oscars/widgets/summary_chip_widget.dart';

class NomineeNominationsDialog extends StatefulWidget {
  final String nominee;
  final String nomineeId;

  const NomineeNominationsDialog({
    super.key,
    required this.nominee,
    required this.nomineeId,
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
        .toList();
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nominations for ${widget.nominee}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                SummaryChip(
                  label: 'Noms',
                  count: nominations,
                  color: Colors.blue,
                ),
                SummaryChip(
                  label: 'Wins',
                  count: wins,
                  color: OscarDesignTokens.oscarGoldDark,
                ),
                SummaryChip(
                  label: 'Special',
                  count: specialAwards,
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
