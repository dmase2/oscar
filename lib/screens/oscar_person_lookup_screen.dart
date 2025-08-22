import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:oscars/design_system/tokens.dart';
import 'package:oscars/models/nominee.dart';
import 'package:oscars/models/oscar_winner.dart';
import 'package:oscars/services/database_service.dart';
import 'package:oscars/services/nominee_nominations_service.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/oscars_app_drawer_widget.dart';
import '../widgets/summary_chip_widget.dart';

class OscarPersonLookupScreen extends StatefulWidget {
  final String? initialNomineeId;
  const OscarPersonLookupScreen({super.key, this.initialNomineeId});

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
  void initState() {
    super.initState();
    // Auto-load person if initial nominee ID is provided
    if (widget.initialNomineeId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadPersonByNomineeId(widget.initialNomineeId!);
      });
    }
  }

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

  void _loadPersonByNomineeId(String nomineeId) {
    final db = DatabaseService.instance;
    final person = db.getNomineeById(nomineeId);
    if (person != null) {
      _onPersonSelected(person);
      _controller.text = person.name;
    }
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

  void _showLinkOptions(
    BuildContext context,
    String nomineeName,
    String nomineeId,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Open $nomineeName'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Where would you like to view more information?'),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.movie, color: Colors.orange),
                title: const Text('IMDb'),
                subtitle: const Text('Internet Movie Database'),
                onTap: () async {
                  Navigator.of(context).pop();
                  await _launchImdbUrl(nomineeName, nomineeId);
                },
              ),
              ListTile(
                leading: const Icon(Icons.public, color: Colors.blue),
                title: const Text('Wikipedia'),
                subtitle: const Text('Free encyclopedia'),
                onTap: () async {
                  Navigator.of(context).pop();
                  await _launchWikipediaUrl(nomineeName, nomineeId);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _launchImdbUrl(String nomineeName, String nomineeId) async {
    try {
      // Construct IMDb URL - IDs should already be in correct format
      String imdbUrl;
      if (nomineeId.startsWith('nm')) {
        // Person ID
        imdbUrl = 'https://www.imdb.com/name/$nomineeId';
      } else if (nomineeId.startsWith('tt')) {
        // Title ID
        imdbUrl = 'https://www.imdb.com/title/$nomineeId';
      } else {
        // Fallback: assume person ID
        imdbUrl = 'https://www.imdb.com/name/nm$nomineeId';
      }

      final url = Uri.parse(imdbUrl);
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not open IMDb: $e')));
      }
    }
  }

  Future<void> _launchWikipediaUrl(String nomineeName, String nomineeId) async {
    try {
      // Create Wikipedia search URL using nominee name
      final encodedName = Uri.encodeComponent(nomineeName);
      final wikipediaUrl =
          'https://en.wikipedia.org/wiki/Special:Search?search=$encodedName';

      final url = Uri.parse(wikipediaUrl);
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not open Wikipedia: $e')));
      }
    }
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
              GestureDetector(
                onTap: () {
                  if ((_selectedPerson?.nomineeId ?? '').isNotEmpty) {
                    _showLinkOptions(
                      context,
                      _selectedPerson!.name,
                      _selectedPerson!.nomineeId,
                    );
                  } else {
                    print('No nominee ID available');
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'No external links available for this person',
                          ),
                        ),
                      );
                    }
                  }
                },
                child: Text(
                  _selectedPerson?.name ?? '',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                children: [
                  SummaryChip(
                    label: 'Nominations',
                    count: _nominationsCount,
                    color: OscarDesignTokens.info,
                  ),
                  const SizedBox(width: 8),
                  SummaryChip(
                    label: 'Wins',
                    count: _winsCount,
                    color: OscarDesignTokens.oscarGoldDark,
                  ),

                  const SizedBox(width: 8),
                  SummaryChip(
                    label: 'Special',
                    count: _specialAwardsCount,
                    color: OscarDesignTokens.special,
                  ),
                ],
              ),

              const SizedBox(height: 8),
              Expanded(
                child: ListView(
                  children: [
                    if (_nominations.isNotEmpty) ...[
                      const Text(
                        'Nominations:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Compact nominations list
                      ..._nominations.map(
                        (n) => Container(
                          margin: const EdgeInsets.symmetric(vertical: 2),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: n.winner
                                ? Theme.of(context).colorScheme.primaryContainer
                                      .withOpacity(0.3)
                                : Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(6),
                            border: n.winner
                                ? Border.all(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary.withOpacity(0.5),
                                  )
                                : null,
                          ),
                          child: Row(
                            children: [
                              // Year badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.outline.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${n.yearFilm}',
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 10,
                                      ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Film and category
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      n.film,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 13,
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      n.category,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withOpacity(0.7),
                                            fontSize: 11,
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              // Winner indicator
                              if (n.winner)
                                const Text(
                                  '🏆',
                                  style: TextStyle(fontSize: 14),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    if (_specialAwards.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Special Awards:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Compact special awards list
                      ..._specialAwards.map(
                        (n) => Container(
                          margin: const EdgeInsets.symmetric(vertical: 2),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.tertiaryContainer.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).colorScheme.tertiary.withOpacity(0.5),
                            ),
                          ),
                          child: Row(
                            children: [
                              // Year badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.tertiary.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${n.yearFilm}',
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 10,
                                      ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Film and category
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      n.film.isNotEmpty ? n.film : n.category,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 13,
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (n.film.isNotEmpty)
                                      Text(
                                        n.category,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withOpacity(0.7),
                                              fontSize: 11,
                                            ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                  ],
                                ),
                              ),
                              // Special award indicator
                              Icon(
                                Icons.star,
                                color: Theme.of(context).colorScheme.tertiary,
                                size: 16,
                              ),
                            ],
                          ),
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
