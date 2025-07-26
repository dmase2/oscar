import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:oscars/models/oscar_winner.dart';
import 'package:oscars/services/database_service.dart';

import '../widgets/oscars_app_drawer_widget.dart';
import '../widgets/summary_chip_widget.dart';

class OscarPersonLookupScreen extends StatefulWidget {
  const OscarPersonLookupScreen({super.key});

  @override
  State<OscarPersonLookupScreen> createState() =>
      _OscarPersonLookupScreenState();
}

class _OscarPersonLookupScreenState extends State<OscarPersonLookupScreen> {
  OscarWinner? _selectedPerson;
  List<OscarWinner> _nominations = [];
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clearSelection() {
    setState(() {
      _selectedPerson = null;
      _nominations = [];
      _controller.clear();
    });
  }

  Future<List<OscarWinner>> _searchPeople(String pattern) async {
    final db = DatabaseService.instance;
    final all = db.getAllOscarWinners();
    final lower = pattern.toLowerCase();
    // Use a set to avoid duplicate names
    final seen = <String>{};
    final filtered = all
        .where(
          (w) => w.nominee.toLowerCase().contains(lower) && seen.add(w.nominee),
        )
        .toList();
    filtered.sort((a, b) => a.nominee.compareTo(b.nominee));
    return filtered;
  }

  void _onPersonSelected(OscarWinner person) {
    final db = DatabaseService.instance;
    setState(() {
      _selectedPerson = person;
      _nominations = db
          .getAllOscarWinners()
          .where((w) => w.nomineeId == person.nomineeId)
          .toList();
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
            TypeAheadField<OscarWinner>(
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
              itemBuilder: (context, OscarWinner suggestion) {
                return ListTile(title: Text(suggestion.nominee));
              },
              onSelected: _onPersonSelected,
              emptyBuilder: (context) =>
                  const ListTile(title: Text('No person found')),
            ),
            const SizedBox(height: 24),

            if (_selectedPerson != null) ...[
              Text(
                _selectedPerson?.nominee ?? '',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              Builder(
                builder: (context) {
                  final specialAwards = _nominations
                      .where((n) => n.className?.toLowerCase() == 'special')
                      .toList();
                  final regularNoms = _nominations
                      .where((n) => n.className?.toLowerCase() != 'special')
                      .toList();
                  final winCount = regularNoms.where((n) => n.winner).length;
                  return Row(
                    children: [
                      SummaryChip(
                        label: 'Nominations',
                        count: regularNoms.length,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 12),
                      SummaryChip(
                        label: 'Wins',
                        count: winCount,
                        color: Colors.amber,
                      ),
                      if (specialAwards.isNotEmpty) ...[
                        const SizedBox(width: 12),
                        SummaryChip(
                          label: 'Special Awards',
                          count: specialAwards.length,
                          color: Colors.green,
                        ),
                      ],
                    ],
                  );
                },
              ),

              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: _nominations.length,
                  itemBuilder: (context, idx) {
                    final n = _nominations[idx];
                    return ListTile(
                      title: Text('${n.film} (${n.yearFilm})'),
                      subtitle: Text(n.category),
                      trailing: n.winner ? const Text('🏆') : null,
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
