import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/oscar_winner.dart';
import '../services/database_service.dart';
import '../widgets/oscars_app_drawer_widget.dart';

final _selectedCategoryProvider = StateProvider<String?>((ref) => null);

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = DatabaseService.instance;
    final allWinners = db.getAllOscarWinners();
    final theme = Theme.of(context);

    // Group by category
    final Map<String, List<OscarWinner>> byCategory = {};
    for (final winner in allWinners) {
      byCategory.putIfAbsent(winner.canonCategory, () => []).add(winner);
    }

    final categoryList = byCategory.keys.toList()..sort();
    final selectedCategory = ref.watch(_selectedCategoryProvider);

    // Calculate stats
    final Map<String, Map<String, int>> nomineeCounts = {};
    final Map<String, Map<String, int>> winnerCounts = {};
    final Map<String, int> overallNominations = {};
    final Map<String, int> overallWins = {};

    for (final winner in allWinners) {
      final cat = winner.canonCategory;
      final nominee = winner.nominee;
      nomineeCounts.putIfAbsent(cat, () => {});
      winnerCounts.putIfAbsent(cat, () => {});
      nomineeCounts[cat]![nominee] = (nomineeCounts[cat]![nominee] ?? 0) + 1;
      overallNominations[nominee] = (overallNominations[nominee] ?? 0) + 1;
      if (winner.winner) {
        winnerCounts[cat]![nominee] = (winnerCounts[cat]![nominee] ?? 0) + 1;
        overallWins[nominee] = (overallWins[nominee] ?? 0) + 1;
      }
    }
    // Remove blank/empty nominee names from overallNominations and overallWins
    overallNominations.removeWhere((key, value) => key.trim().isEmpty);
    overallWins.removeWhere((key, value) => key.trim().isEmpty);

    // Helper function to get top N with ties
    List<MapEntry<String, int>> topWithTies(Map<String, int> map, int n) {
      final entries = map.entries.toList();
      entries.sort((a, b) => b.value.compareTo(a.value));
      if (entries.length <= n) return entries;
      final cutoff = entries[n - 1].value;
      final result = entries.take(n).toList();
      result.addAll(entries.skip(n).where((e) => e.value == cutoff));
      // Remove duplicates if any
      final seen = <String>{};
      return result.where((e) => seen.add(e.key)).toList();
    }

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
                Text(
                  'Top Nominees and Winners by Category',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                ...[
                  for (final cat in categoryList)
                    if (selectedCategory == null || selectedCategory == cat)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 12, bottom: 4),
                            child: Text(
                              cat,
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
                          ...topWithTies(
                            nomineeCounts[cat]!,
                            selectedCategory != null ? 10 : 5,
                          ).map(
                            (e) => Text(
                              '${e.key}: ${e.value} nominations',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface,
                              ),
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
                          ...topWithTies(
                            winnerCounts[cat]!,
                            selectedCategory != null ? 10 : 5,
                          ).map(
                            (e) => Text(
                              '${e.key}: ${e.value} wins',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                ],
                // Only show overall stats if no category filter is applied
                if (selectedCategory == null) ...[
                  const SizedBox(height: 24),
                  Text(
                    'Overall Top Nominees',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  ...topWithTies(overallNominations, 10).map(
                    (e) => Text(
                      '${e.key}: ${e.value} nominations',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Overall Top Winners',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  ...topWithTies(overallWins, 10).map(
                    (e) => Text(
                      '${e.key}: ${e.value} wins',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
