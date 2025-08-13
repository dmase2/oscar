import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:oscars/models/nominee.dart';
import 'package:oscars/models/oscar_winner.dart';
import 'package:oscars/services/database_service.dart';
import 'package:oscars/services/nominee_nominations_service.dart';

import '../widgets/oscars_app_drawer_widget.dart';
import '../widgets/summary_chip_widget.dart';

class OscarPersonLookupScreen extends StatefulWidget {
  const OscarPersonLookupScreen({super.key});

  @override
  State<OscarPersonLookupScreen> createState() =>
      _OscarPersonLookupScreenState();
}

class _OscarPersonLookupScreenState extends State<OscarPersonLookupScreen> {
  Nominee? _selectedPerson;
  List<OscarWinner> _nominations = [];
  List<OscarWinner> _specialAwards = [];
  int _nominationsCount = 0;
  int _winsCount = 0;
  int _specialAwardsCount = 0;
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<List<Nominee>> _searchPeople(String pattern) async {
    final db = DatabaseService.instance;
    final all = db.getAllNominees();
    final lower = pattern.toLowerCase();
    final filtered = all
        .where((nominee) => nominee.name.toLowerCase().contains(lower))
        .toList();
    filtered.sort((a, b) => a.name.compareTo(b.name));
    return filtered;
  }

  void _onPersonSelected(Nominee person) {
    final db = DatabaseService.instance;
    final allWinners = db.getAllOscarWinners();

    // Get all nominations for this person's nominee ID
    final allNoms = allWinners.where((w) {
      final winnerIds = w.nomineeId.split('|').map((n) => n.trim()).toSet();
      return winnerIds.contains(person.nomineeId);
    }).toList();

    // Calculate stats for this nominee ID
    final stats = NomineeNominationsService.getNomineeNominations(
      allWinners,
      person.nomineeId,
    );

    // Deduplicate special awards by (category, yearFilm)
    final specialAwardsMap = <String, OscarWinner>{};
    for (final n in allNoms.where(
      (n) => n.category.toLowerCase().contains('special'),
    )) {
      final key = '${n.category.trim().toLowerCase()}|${n.yearFilm}';
      specialAwardsMap[key] = n;
    }
    final specialAwards = specialAwardsMap.values.toList();
    final regularNoms = allNoms
        .where((n) => !n.category.toLowerCase().contains('special'))
        .toList();
    setState(() {
      _selectedPerson = person;
      _nominations = regularNoms;
      _specialAwards = specialAwards;
      _nominationsCount = stats.nominations;
      _winsCount = stats.wins;
      _specialAwardsCount = stats.specialAwards;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Oscar Person Lookup')),
      drawer: const OscarsAppDrawer(selected: 'lookup'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TypeAheadField<Nominee>(
              suggestionsCallback: _searchPeople,
              builder: (context, controller, focusNode) {
                return TextField(
                  controller: controller, // Use the provided controller
                  focusNode: focusNode, // Use the provided focusNode
                  decoration: InputDecoration(
                    labelText: 'Search for a person',
                    border: const OutlineInputBorder(),
                    suffixIcon: _selectedPerson != null
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _selectedPerson = null;
                                _nominations = [];
                                controller.clear();
                              });
                            },
                          )
                        : null,
                  ),
                );
              },
              itemBuilder: (context, Nominee suggestion) {
                return ListTile(title: Text(suggestion.name));
              },
              onSelected: _onPersonSelected,
              emptyBuilder: (context) =>
                  const ListTile(title: Text('No person found')),
            ),
            const SizedBox(height: 24),

            if (_selectedPerson != null) ...[
              Text(
                _selectedPerson?.name ?? '',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                children: [
                  SummaryChip(
                    label: 'Nominations',
                    count: _nominationsCount,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 12),
                  SummaryChip(
                    label: 'Wins',
                    count: _winsCount,
                    color: Colors.amber,
                  ),
                  if (_specialAwardsCount > 0) ...[
                    const SizedBox(width: 12),
                    SummaryChip(
                      label: 'Special',
                      count: _specialAwardsCount,
                      color: Colors.green,
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 8),
              Expanded(
                child: ListView(
                  children: [
                    if (_nominations.isNotEmpty) ...[
                      const Text(
                        'Nominations:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      ..._nominations.map(
                        (n) => ListTile(
                          title: Text('${n.film} (${n.yearFilm})'),
                          subtitle: Text(n.category),
                          trailing: n.winner ? const Text('🏆') : null,
                        ),
                      ),
                    ],
                    if (_specialAwards.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Special Awards:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      ..._specialAwards.map(
                        (n) => ListTile(
                          title: Text(
                            '${n.film.isNotEmpty ? n.film : n.category} (${n.yearFilm})',
                          ),
                          subtitle: Text(n.category),
                          trailing: const Icon(Icons.star, color: Colors.green),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
