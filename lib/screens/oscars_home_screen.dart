// Removed duplicate _selectedYearProvider declaration

// ...existing code...

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/oscar_providers.dart';
import '../widgets/category_dropdown_widget.dart';
import '../widgets/oscar_movie_grid_widget.dart';
import '../widgets/oscars_app_drawer_widget.dart';

final _selectedYearProvider = StateProvider<int?>((ref) => null);

// Define a constant for the sentinel value for "All Years"
const int kAllYears = -1;

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDecade = ref.watch(selectedDecadeProvider);
    final availableDecadesAsync = ref.watch(availableDecadesProvider);
    final oscarsByDecadeAsync = ref.watch(
      oscarsByDecadeProvider(selectedDecade ?? 2020),
    );
    final selectedCategory = ref.watch(_selectedCategoryProvider);
    final showOnlyWinners = ref.watch(_showOnlyWinnersProvider);
    final selectedYear = ref.watch(_selectedYearProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(showOnlyWinners ? 'Oscar Winners' : 'Oscar Nominees'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        toolbarHeight: 60, // Reset to default or smaller height
        actions: [
          // Decade dropdown (PopupMenuButton style)
          availableDecadesAsync.when(
            data: (decades) {
              final sortedDecades = [...decades]
                ..sort((a, b) => b.compareTo(a));
              if (selectedDecade == null && sortedDecades.isNotEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ref.read(selectedDecadeProvider.notifier).state =
                      sortedDecades.first;
                });
              }
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
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        selectedDecade != null
                            ? '${selectedDecade}s'
                            : 'Select Decade',
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
          // Year dropdown (PopupMenuButton style)
          oscarsByDecadeAsync.when(
            data: (oscars) {
              final availableYears =
                  oscars.map((o) => o.yearFilm).toSet().toList()..sort();

              // Updated Year dropdown using non-nullable int with a sentinel value for "All Years"
              return PopupMenuButton<int>(
                onSelected: (year) {
                  if (year == kAllYears) {
                    ref.read(_selectedYearProvider.notifier).state = null;
                  } else {
                    ref.read(_selectedYearProvider.notifier).state = year;
                  }
                },
                itemBuilder: (context) => [
                  // "All Years" option using sentinel value
                  PopupMenuItem<int>(
                    value: kAllYears,
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'All Years',
                        style: TextStyle(
                          fontWeight: selectedYear == null
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      trailing: selectedYear == null
                          ? Icon(
                              Icons.check,
                              color: Theme.of(context).colorScheme.primary,
                              size: 16,
                            )
                          : null,
                    ),
                  ),
                  const PopupMenuDivider(),
                  // Year options
                  ...availableYears.map(
                    (year) => PopupMenuItem<int>(
                      value: year,
                      height: 14,
                      child: ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          year.toString(),
                          style: TextStyle(
                            fontWeight: year == selectedYear
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 14.0,
                          ),
                        ),
                        trailing: year == selectedYear
                            ? Icon(
                                Icons.check,
                                color: Theme.of(context).colorScheme.primary,
                                size: 16,
                              )
                            : null,
                      ),
                    ),
                  ),
                ],
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        selectedYear == null
                            ? 'All Years'
                            : selectedYear.toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (error, stack) => const SizedBox.shrink(),
          ),
        ],
      ),
      drawer: const OscarsAppDrawer(selected: 'home'),
      body: Column(
        children: [
          // Category and winner filter row (use oscarsByDecadeAsync)
          oscarsByDecadeAsync.when(
            data: (oscars) {
              final canonCategories = oscars
                  .map((o) => o.canonCategory)
                  .toSet()
                  .toList();

              // Debug: Print first few categories to see actual names
              debugPrint(
                'Sample categories: ${canonCategories.take(10).toList()}',
              );

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: CategoryDropdownWidget(
                            selectedCategory: selectedCategory == '__ACTING__'
                                ? '__ACTING__'
                                : canonCategories.contains(selectedCategory)
                                ? selectedCategory
                                : null,
                            categoryList: canonCategories,
                            onChanged: (value) {
                              ref
                                      .read(_selectedCategoryProvider.notifier)
                                      .state =
                                  value;
                            },
                            hintText: 'Filter by category',
                            showAllOscars: false,
                            actingCategoriesValue: '__ACTING__',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Row(
                          children: [
                            const Text('Winners only'),
                            Switch(
                              value: showOnlyWinners,
                              onChanged: (value) {
                                ref
                                        .read(_showOnlyWinnersProvider.notifier)
                                        .state =
                                    value;
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (error, stack) => const SizedBox.shrink(),
          ),
          Expanded(
            child: oscarsByDecadeAsync.when(
              data: (oscars) {
                final filtered = oscars.where((oscar) {
                  final yearMatch =
                      selectedYear == null || oscar.yearFilm == selectedYear;
                  if (selectedCategory == null) {
                    return yearMatch &&
                        (showOnlyWinners ? oscar.winner == true : true);
                  } else if (selectedCategory == '__ACTING__') {
                    // Special filter for all acting nominations using className
                    return yearMatch &&
                        oscar.className?.toLowerCase() == 'acting' &&
                        (showOnlyWinners ? oscar.winner == true : true);
                  } else {
                    return yearMatch &&
                        oscar.canonCategory == selectedCategory &&
                        (showOnlyWinners ? oscar.winner == true : true);
                  }
                }).toList();
                return filtered.isEmpty
                    ? const Center(
                        child: Text(
                          'No nominees found for this category, year, and decade',
                        ),
                      )
                    : OscarMovieGrid(oscars: filtered);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error,
                      size: 64,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text('Error loading Oscar data: $error'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.refresh(
                        oscarsByDecadeProvider(selectedDecade ?? 2020),
                      ),
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

// final availableCategories = [
//   'ACTOR',
//   'ACTRESS',
//   'DIRECTOR',
//   'BEST PICTURE',
//   'CINEMATOGRAPHY',
//   'VISUAL EFFECTS',
// ];

final priorityCategories = [
  'ACTOR IN A LEADING ROLE',
  'ACTOR IN A SUPPORTING ROLE',
  'ACTRESS IN A LEADING ROLE',
  'ACTRESS IN A SUPPORTING ROLE',
  'DIRECTOR',
  'BEST PICTURE',
  'CINEMATOGRAPHY',
  'WRITING (Adapted Screenplay)',
  'WRITING (Original Screenplay)',
];
final selectedCategoriesProvider = StateProvider<List<String>>((ref) => []);

final _selectedCategoryProvider = StateProvider<String?>((ref) => null);

final _showOnlyWinnersProvider = StateProvider<bool>((ref) => true);
