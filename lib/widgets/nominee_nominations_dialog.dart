import 'package:flutter/material.dart';
import 'package:oscars/services/database_service.dart';
import 'package:oscars/services/nominee_nominations_service.dart';

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
        .where((w) => w.nomineeId == widget.nomineeId)
        .toList();
    return AlertDialog(
      title: Text('Nominations for ${widget.nominee}'),
      surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
      scrollable: true,
      shadowColor: Theme.of(context).colorScheme.surface,
      content: SizedBox(
        width: 500, // Increased width to fit long category names
        height: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: Chip(
                      label: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text('Noms: $nominations'),
                      ),
                      backgroundColor: Colors.grey[200],
                      labelStyle: const TextStyle(color: Colors.blue),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: Chip(
                      label: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text('Wins: $wins'),
                      ),
                      backgroundColor: Colors.grey[200],
                      labelStyle: const TextStyle(color: Colors.deepOrange),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: Chip(
                      label: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text('Special: $specialAwards'),
                      ),
                      backgroundColor: Colors.grey[200],
                      labelStyle: const TextStyle(color: Colors.green),
                    ),
                  ),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: Scrollbar(
                thumbVisibility: true,
                controller: _scrollController,
                child: ListView.builder(
                  controller: _scrollController,
                  physics: movies.length > 5
                      ? null
                      : const NeverScrollableScrollPhysics(),
                  shrinkWrap: movies.length <= 5,
                  itemCount: movies.length,
                  itemBuilder: (context, idx) {
                    final m = movies[idx];
                    return ListTile(
                      title: Text(m.film),
                      subtitle: Text(
                        '${m.yearFilm} - ${m.category} ${m.winner ? '🏆' : ''}',
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
