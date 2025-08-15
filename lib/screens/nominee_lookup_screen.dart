import 'package:flutter/material.dart';

import '../models/nominee.dart';
import '../models/oscar_winner.dart';
import '../services/database_service.dart';
import '../services/nominee_nominations_service.dart';
import '../widgets/oscars_app_drawer_widget.dart';

class NomineeLookupScreen extends StatefulWidget {
  const NomineeLookupScreen({super.key});

  @override
  State<NomineeLookupScreen> createState() => _NomineeLookupScreenState();
}

class _NomineeLookupScreenState extends State<NomineeLookupScreen> {
  final TextEditingController _controller = TextEditingController();
  String? _selectedNomineeId;
  Nominee? _selectedNominee;
  List<OscarWinner> _nominations = [];
  bool _loading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _lookupNominee(String nomineeId) async {
    setState(() {
      _loading = true;
      _selectedNomineeId = nomineeId;
      _selectedNominee = null;
      _nominations = [];
    });

    final db = DatabaseService.instance;
    final nominee = db.getNomineeById(nomineeId);

    if (nominee != null) {
      // Get all Oscar winners for this nominee
      final allWinners = db.getAllOscarWinners();
      final nomineeWinners = allWinners
          .where(
            (w) =>
                w.nomineeId.split('|').map((n) => n.trim()).contains(nomineeId),
          )
          .toList();

      setState(() {
        _selectedNominee = nominee;
        _nominations = nomineeWinners;
        _loading = false;
      });
    } else {
      setState(() {
        _loading = false;
      });
    }
  }

  void _printNominations() {
    if (_selectedNominee == null || _nominations.isEmpty) return;

    print(
      '=== NOMINATIONS FOR ${_selectedNominee!.name} (ID: ${_selectedNominee!.nomineeId}) ===',
    );
    print('Total nominations found: ${_nominations.length}');
    print('Films in nominee record: ${_selectedNominee!.filmIds}');
    print('');

    for (int i = 0; i < _nominations.length; i++) {
      final nom = _nominations[i];
      print('${i + 1}. ${nom.film} (${nom.yearFilm})');
      print('   Category: ${nom.category}');
      print('   Winner: ${nom.winner ? "YES" : "NO"}');
      print('   Film ID: ${nom.filmId}');
      print('   Nominees: ${nom.nominee}');
      print('   Nominee IDs: ${nom.nomineeId}');
      if (nom.note.isNotEmpty) {
        print('   Note: ${nom.note}');
      }
      print('');
    }

    // Show statistics
    final stats = NomineeNominationsService.getNomineeNominations(
      _nominations,
      _selectedNomineeId!,
    );
    print('STATISTICS:');
    print('Regular nominations: ${stats.nominations}');
    print('Wins: ${stats.wins}');
    print('Special awards: ${stats.specialAwards}');
    print('========================================');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nominee Lookup')),
      drawer: const OscarsAppDrawer(selected: 'nominee_lookup'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Enter Nominee ID',
                border: OutlineInputBorder(),
                hintText: 'e.g., nm0000102',
              ),
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  _lookupNominee(value.trim());
                }
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    final id = _controller.text.trim();
                    if (id.isNotEmpty) {
                      _lookupNominee(id);
                    }
                  },
                  child: const Text('Lookup'),
                ),
                const SizedBox(width: 16),
                if (_nominations.isNotEmpty)
                  ElevatedButton(
                    onPressed: _printNominations,
                    child: const Text('Print to Console'),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_selectedNominee != null) ...[
              Text(
                _selectedNominee!.name,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text('ID: ${_selectedNominee!.nomineeId}'),
              const SizedBox(height: 16),
              Text('Films: ${_nominations.length}'),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _nominations.length,
                  itemBuilder: (context, index) {
                    final nom = _nominations[index];
                    return Card(
                      child: ListTile(
                        title: Text('${nom.film} (${nom.yearFilm})'),
                        subtitle: Text(
                          '${nom.category}${nom.winner ? " - WINNER" : ""}',
                        ),
                        trailing: nom.winner
                            ? Icon(
                                Icons.stars,
                                color: Theme.of(context).colorScheme.primary,
                              )
                            : null,
                      ),
                    );
                  },
                ),
              ),
            ] else if (_selectedNomineeId != null)
              const Text('No nominee found with that ID.'),
          ],
        ),
      ),
    );
  }
}
