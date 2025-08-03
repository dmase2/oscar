import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/oscar_winner.dart';
import '../services/database_service.dart';
import '../widgets/nominee_nominations_dialog.dart';
import '../widgets/oscars_app_drawer_widget.dart';

/// Holds statistics for nominees and winners.
class _StatisticsResult {
  final Map<String, Map<String, int>> nomineeCounts;
  final Map<String, Map<String, int>> winnerCounts;
  final Map<String, int> overallNominations;
  final Map<String, int> overallWins;
  _StatisticsResult({
    required this.nomineeCounts,
    required this.winnerCounts,
    required this.overallNominations,
    required this.overallWins,
  });
}

/// Computes statistics for the current filter selection.
_StatisticsResult _computeStatistics({
  required String? selectedCategory,
  required Map<String, List<OscarWinner>> byNomineeId,
  required Map<String, Map<String, List<OscarWinner>>> byCategoryAndNominee,
  required List<String> actingCategories,
}) {
  final nomineeCounts = <String, Map<String, int>>{};
  final winnerCounts = <String, Map<String, int>>{};
  final overallNominations = <String, int>{};
  final overallWins = <String, int>{};

  if (selectedCategory == 'ALL_OSCARS' || selectedCategory == null) {
    for (final nomineeId in byNomineeId.keys) {
      final nomineeMovies = byNomineeId[nomineeId]!;
      final nomineeName = nomineeMovies.first.nominee;
      if (nomineeName.trim().isEmpty) continue;
      final overallNomPairs = <String>{};
      final overallWinPairs = <String>{};
      for (final movie in nomineeMovies) {
        if ((movie.className?.toLowerCase() ?? '') == 'special') continue;
        final key = '${movie.canonCategory}|${movie.yearFilm}';
        overallNomPairs.add(key);
        if (movie.winner) overallWinPairs.add(key);
      }
      overallNominations[nomineeName] = overallNomPairs.length;
      overallWins[nomineeName] = overallWinPairs.length;
      if (selectedCategory == null) {
        for (final category
            in nomineeMovies.map((m) => m.canonCategory).toSet()) {
          final categoryMovies = nomineeMovies
              .where((m) => m.canonCategory == category)
              .toList();
          final catNomPairs = <String>{};
          final catWinPairs = <String>{};
          for (final movie in categoryMovies) {
            if ((movie.className?.toLowerCase() ?? '') == 'special') continue;
            final key = '${movie.canonCategory}|${movie.yearFilm}';
            catNomPairs.add(key);
            if (movie.winner) catWinPairs.add(key);
          }
          nomineeCounts.putIfAbsent(category, () => {});
          winnerCounts.putIfAbsent(category, () => {});
          nomineeCounts[category]![nomineeName] = catNomPairs.length;
          winnerCounts[category]![nomineeName] = catWinPairs.length;
        }
      }
    }
  } else if (selectedCategory == 'ALL_ACTING') {
    final actingByNominee = <String, List<OscarWinner>>{};
    for (final cat in actingCategories) {
      final nomineeMap = byCategoryAndNominee[cat] ?? {};
      for (final entry in nomineeMap.entries) {
        actingByNominee.putIfAbsent(entry.key, () => []).addAll(entry.value);
      }
    }
    for (final nomineeId in actingByNominee.keys) {
      final nomineeMovies = actingByNominee[nomineeId]!;
      final nomineeName = nomineeMovies.first.nominee;
      if (nomineeName.trim().isEmpty) continue;
      final nominationPairs = <String>{};
      final winPairs = <String>{};
      for (final movie in nomineeMovies) {
        if ((movie.className?.toLowerCase() ?? '') == 'special') continue;
        final key = '${movie.canonCategory}|${movie.yearFilm}';
        nominationPairs.add(key);
        if (movie.winner) winPairs.add(key);
      }
      nomineeCounts['ALL_ACTING'] ??= {};
      winnerCounts['ALL_ACTING'] ??= {};
      nomineeCounts['ALL_ACTING']![nomineeName] = nominationPairs.length;
      winnerCounts['ALL_ACTING']![nomineeName] = winPairs.length;
    }
  } else {
    final nomineeMap = byCategoryAndNominee[selectedCategory] ?? {};
    for (final entry in nomineeMap.entries) {
      final nomineeMovies = entry.value;
      final nomineeName = nomineeMovies.first.nominee;
      if (nomineeName.trim().isEmpty) continue;
      final nominationPairs = <String>{};
      final winPairs = <String>{};
      for (final movie in nomineeMovies) {
        if ((movie.className?.toLowerCase() ?? '') == 'special') continue;
        final key = '${movie.canonCategory}|${movie.yearFilm}';
        nominationPairs.add(key);
        if (movie.winner) winPairs.add(key);
      }
      nomineeCounts[selectedCategory] ??= {};
      winnerCounts[selectedCategory] ??= {};
      nomineeCounts[selectedCategory]![nomineeName] = nominationPairs.length;
      winnerCounts[selectedCategory]![nomineeName] = winPairs.length;
    }
  }
  return _StatisticsResult(
    nomineeCounts: nomineeCounts,
    winnerCounts: winnerCounts,
    overallNominations: overallNominations,
    overallWins: overallWins,
  );
}

/// Provider for the currently selected category filter.
final _selectedCategoryProvider = StateProvider<String?>((ref) => null);

/// Displays Oscar statistics with category and group filtering.
class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = DatabaseService.instance;
    final allWinners = db.getAllOscarWinners();
    final theme = Theme.of(context);

    // Pre-group by nomineeId and by category for fast lookup
    final byNomineeId = <String, List<OscarWinner>>{};
    final byCategoryAndNominee = <String, Map<String, List<OscarWinner>>>{};
    final byCategory = <String, List<OscarWinner>>{};
    for (final winner in allWinners) {
      if (winner.nomineeId.trim().isEmpty) continue;
      byNomineeId.putIfAbsent(winner.nomineeId, () => []).add(winner);
      byCategory.putIfAbsent(winner.canonCategory, () => []).add(winner);
      byCategoryAndNominee
          .putIfAbsent(winner.canonCategory, () => {})
          .putIfAbsent(winner.nomineeId, () => [])
          .add(winner);
    }

    // Acting categories for group filter
    const actingCategories = [
      'ACTOR IN A LEADING ROLE',
      'ACTRESS IN A LEADING ROLE',
      'ACTOR IN A SUPPORTING ROLE',
      'ACTRESS IN A SUPPORTING ROLE',
      'BEST ACTOR',
      'BEST ACTRESS',
      'BEST SUPPORTING ACTOR',
      'BEST SUPPORTING ACTRESS',
    ];
    final categoryList = byCategory.keys.toList()..sort();
    final selectedCategory = ref.watch(_selectedCategoryProvider);

    // Compute statistics for the current filter
    final stats = _computeStatistics(
      selectedCategory: selectedCategory,
      byNomineeId: byNomineeId,
      byCategoryAndNominee: byCategoryAndNominee,
      actingCategories: actingCategories,
    );
    final nomineeCounts = stats.nomineeCounts;
    final winnerCounts = stats.winnerCounts;
    final overallNominations = stats.overallNominations;
    final overallWins = stats.overallWins;

    return Scaffold(
      appBar: AppBar(
        title: Text('Oscar Statistics', style: theme.textTheme.titleLarge),
        backgroundColor: theme.colorScheme.inversePrimary,
        toolbarHeight: 60,
      ),
      drawer: const OscarsAppDrawer(selected: 'statistics'),
      backgroundColor: theme.colorScheme.surface,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButton<String?>(
              value: selectedCategory,
              hint: const Text('Filter by category'),
              isExpanded: true,
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('All Categories'),
                ),
                const DropdownMenuItem<String?>(
                  value: 'ALL_OSCARS',
                  child: Text('All Oscars'),
                ),
                const DropdownMenuItem<String?>(
                  value: 'ALL_ACTING',
                  child: Text('All Acting'),
                ),
                ...categoryList.map(
                  (cat) =>
                      DropdownMenuItem<String?>(value: cat, child: Text(cat)),
                ),
              ],
              onChanged: (value) {
                ref.read(_selectedCategoryProvider.notifier).state = value;
              },
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (selectedCategory == 'ALL_OSCARS') ...[
                  _buildTopSection(
                    context,
                    theme,
                    'Top Oscar Nominees (All Categories)',
                    overallNominations,
                    allWinners,
                    'nominations',
                  ),
                  const SizedBox(height: 24),
                  _buildTopSection(
                    context,
                    theme,
                    'Top Oscar Winners (All Categories)',
                    overallWins,
                    allWinners,
                    'wins',
                  ),
                ] else if (selectedCategory == 'ALL_ACTING') ...[
                  _buildTopSection(
                    context,
                    theme,
                    'Top Acting Nominees',
                    nomineeCounts['ALL_ACTING'] ?? {},
                    allWinners,
                    'nominations',
                  ),
                  const SizedBox(height: 24),
                  _buildTopSection(
                    context,
                    theme,
                    'Top Acting Winners',
                    winnerCounts['ALL_ACTING'] ?? {},
                    allWinners,
                    'wins',
                  ),
                ] else ...[
                  Text(
                    'Top Nominees and Winners by Category',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  for (final cat in categoryList)
                    if (selectedCategory == null || selectedCategory == cat)
                      _buildCategorySection(
                        context,
                        theme,
                        cat,
                        nomineeCounts[cat] ?? {},
                        winnerCounts[cat] ?? {},
                        allWinners,
                        selectedCategory == null ? 10 : 5,
                      ),
                  if (selectedCategory == null) ...[
                    const SizedBox(height: 24),
                    _buildTopSection(
                      context,
                      theme,
                      'Overall Top Nominees',
                      overallNominations,
                      allWinners,
                      'nominations',
                    ),
                    const SizedBox(height: 24),
                    _buildTopSection(
                      context,
                      theme,
                      'Overall Top Winners',
                      overallWins,
                      allWinners,
                      'wins',
                    ),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a section for a single category, showing top nominees and winners.
  Widget _buildCategorySection(
    BuildContext context,
    ThemeData theme,
    String category,
    Map<String, int> nominations,
    Map<String, int> wins,
    List<OscarWinner> allWinners,
    int topCount,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 4),
          child: Text(
            category,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 2),
          child: Text(
            'Top Nominations:',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        ..._getTopWithTies(nominations, topCount).map(
          (e) => _buildNomineeEntry(
            context,
            theme,
            e.key,
            e.value,
            'nominations',
            allWinners,
            true,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 2),
          child: Text(
            'Top Winners:',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        ..._getTopWithTies(wins, topCount).map(
          (e) => _buildNomineeEntry(
            context,
            theme,
            e.key,
            e.value,
            'wins',
            allWinners,
            true,
          ),
        ),
      ],
    );
  }

  /// Builds a clickable or plain nominee entry row.
  Widget _buildNomineeEntry(
    BuildContext context,
    ThemeData theme,
    String nomineeName,
    int count,
    String type,
    List<OscarWinner> allWinners,
    bool isClickable,
  ) {
    final widget = Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Text(
        '$nomineeName: $count $type',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface,
          decoration: isClickable ? TextDecoration.underline : null,
        ),
      ),
    );

    if (!isClickable) return widget;

    return InkWell(
      onTap: () {
        final nomineeId = allWinners
            .firstWhere(
              (w) => w.nominee == nomineeName,
              orElse: () => OscarWinner(
                yearFilm: 0,
                yearCeremony: 0,
                ceremony: 0,
                category: '',
                canonCategory: '',
                name: '',
                film: '',
                filmId: '',
                nominee: '',
                nomineeId: '',
                winner: false,
                detail: '',
                note: '',
                citation: '',
              ),
            )
            .nomineeId;
        if (nomineeId.isNotEmpty) {
          showDialog(
            context: context,
            builder: (context) => NomineeNominationsDialog(
              nominee: nomineeName,
              nomineeId: nomineeId,
            ),
          );
        }
      },
      child: widget,
    );
  }

  /// Returns the top N entries, including ties at the cutoff.
  List<MapEntry<String, int>> _getTopWithTies(Map<String, int> map, int n) {
    if (map.isEmpty) return [];
    final entries = map.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    if (entries.length <= n) return entries;
    final cutoff = entries[n - 1].value;
    final result = entries.take(n).toList();
    result.addAll(entries.skip(n).where((e) => e.value == cutoff));
    final seen = <String>{};
    return result.where((e) => seen.add(e.key)).toList();
  }

  /// Builds a section for top nominees or winners.
  Widget _buildTopSection(
    BuildContext context,
    ThemeData theme,
    String title,
    Map<String, int> data,
    List<OscarWinner> allWinners,
    String type,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        ..._getTopWithTies(data, 10).map(
          (e) => _buildNomineeEntry(
            context,
            theme,
            e.key,
            e.value,
            type,
            allWinners,
            true,
          ),
        ),
      ],
    );
  }

  /// Holds statistics for nominees and winners.
}
