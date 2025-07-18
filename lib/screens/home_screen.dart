import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/oscar_providers.dart';
import 'settings_screen.dart';
import '../widgets/oscar_movie_grid.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDecade = ref.watch(selectedDecadeProvider);
    final availableDecadesAsync = ref.watch(availableDecadesProvider);
    final oscarsByDecadeAsync = ref.watch(
      oscarsByDecadeProvider(selectedDecade),
    );
    final selectedCategory = ref.watch(_selectedCategoryProvider);
    final showOnlyWinners = ref.watch(_showOnlyWinnersProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(showOnlyWinners ? 'Oscar Winners' : 'Oscar Nominees'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        toolbarHeight: 60, // Reset to default or smaller height
        actions: [
          availableDecadesAsync.when(
            data: (decades) {
              final sortedDecades = [...decades]..sort();
              return PopupMenuButton<int>(
                onSelected: (decade) {
                  ref.read(selectedDecadeProvider.notifier).state = decade;
                },
                itemBuilder: (context) => sortedDecades
                    .map(
                      (decade) => PopupMenuItem(
                        value: decade,
                        child: Text(
                          '${decade}s',
                          style: TextStyle(
                            fontWeight: decade == selectedDecade
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${selectedDecade}s',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              );
            },
            loading: () => const CircularProgressIndicator(),
            error: (error, stack) => const Icon(Icons.error),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          oscarsByDecadeAsync.when(
            data: (oscars) {
              final canonCategories =
                  oscars.map((o) => o.canonCategory).toSet().toList()..sort();
              // If the selected category is not in the new list, reset it
              if (selectedCategory != null &&
                  !canonCategories.contains(selectedCategory)) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ref.read(_selectedCategoryProvider.notifier).state = null;
                });
              }
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButton<String>(
                        value: canonCategories.contains(selectedCategory)
                            ? selectedCategory
                            : null,
                        hint: const Text('Filter by category'),
                        isExpanded: true,
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('All Categories'),
                          ),
                          ...canonCategories.map(
                            (cat) => DropdownMenuItem<String>(
                              value: cat,
                              child: Text(cat),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          ref.read(_selectedCategoryProvider.notifier).state =
                              value;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Row(
                      children: [
                        const Text('Winners only'),
                        Switch(
                          value: showOnlyWinners,
                          onChanged: (value) {
                            ref.read(_showOnlyWinnersProvider.notifier).state =
                                value;
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (error, stack) => const SizedBox.shrink(),
          ),
          Expanded(
            child: oscarsByDecadeAsync.when(
              data: (oscars) {
                final filtered = oscars.where((oscar) {
                  if (selectedCategory == null) {
                    return showOnlyWinners ? oscar.winner == true : true;
                  } else {
                    return oscar.canonCategory == selectedCategory &&
                        (showOnlyWinners ? oscar.winner == true : true);
                  }
                }).toList();
                return filtered.isEmpty
                    ? const Center(
                        child: Text(
                          'No nominees found for this category and decade',
                        ),
                      )
                    : OscarMovieGrid(oscars: filtered);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error loading Oscar data: $error'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          ref.refresh(oscarsByDecadeProvider(selectedDecade)),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

final availableCategories = [
  'ACTOR',
  'ACTRESS',
  'DIRECTOR',
  'BEST PICTURE',
  'CINEMATOGRAPHY',
  'VISUAL EFFECTS',
];

final selectedCategoriesProvider = StateProvider<List<String>>((ref) => []);

final _selectedCategoryProvider = StateProvider<String?>((ref) => null);

final _showOnlyWinnersProvider = StateProvider<bool>((ref) => true);
