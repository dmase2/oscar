import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oscars/design_system/design_system.dart';
import 'package:oscars/widgets/omdb_info_box_widget.dart';
import 'package:oscars/widgets/oscar_detail_widget.dart';

import '../models/oscar_winner.dart';
import '../providers/oscar_providers.dart';
import '../screens/oscar_person_lookup_screen.dart';
import '../utils/nominee_parser.dart';
import '../widgets/oscars_app_drawer_widget.dart';
import '../widgets/poster_image_widget.dart';
import '../widgets/summary_chip_widget.dart';

class MovieDetailScreen extends StatelessWidget {
  final OscarWinner oscar;
  final List<OscarWinner>? allOscars;
  final int? currentIndex;

  const MovieDetailScreen({
    super.key,
    required this.oscar,
    this.allOscars,
    this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          oscar.film,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      drawer: const OscarsAppDrawer(),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (allOscars != null && currentIndex != null) {
            // Swipe left to go to next
            if (details.primaryVelocity != null &&
                details.primaryVelocity! < 0 &&
                currentIndex! < allOscars!.length - 1) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => MovieDetailScreen(
                    oscar: allOscars![currentIndex! + 1],
                    allOscars: allOscars,
                    currentIndex: currentIndex! + 1,
                  ),
                ),
              );
            }
            // Swipe right to go to previous
            if (details.primaryVelocity != null &&
                details.primaryVelocity! > 0 &&
                currentIndex! > 0) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => MovieDetailScreen(
                    oscar: allOscars![currentIndex! - 1],
                    allOscars: allOscars,
                    currentIndex: currentIndex! - 1,
                  ),
                ),
              );
            }
          }
        },
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left, size: 40),
                          tooltip: 'Previous',
                          onPressed:
                              (allOscars != null &&
                                  currentIndex != null &&
                                  currentIndex! > 0)
                              ? () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MovieDetailScreen(
                                        oscar: allOscars![currentIndex! - 1],
                                        allOscars: allOscars,
                                        currentIndex: currentIndex! - 1,
                                      ),
                                    ),
                                  );
                                }
                              : null,
                        ),
                        Expanded(
                          child: Center(
                            child: Hero(
                              tag:
                                  'poster_${oscar.film}_${oscar.yearFilm}_${oscar.name}_${oscar.hashCode}',
                              child: Container(
                                width: 200,
                                height: 300,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainerHighest,
                                ),
                                child: GestureDetector(
                                  child: PosterImageWidget(oscar: oscar),
                                  onTap: () =>
                                      showOmdbInfoDialog(context, oscar),
                                ),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right, size: 40),
                          tooltip: 'Next',
                          onPressed:
                              (allOscars != null &&
                                  currentIndex != null &&
                                  currentIndex! < allOscars!.length - 1)
                              ? () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MovieDetailScreen(
                                        oscar: allOscars![currentIndex! + 1],
                                        allOscars: allOscars,
                                        currentIndex: currentIndex! + 1,
                                      ),
                                    ),
                                  );
                                }
                              : null,
                        ),
                      ],
                    ),

                    OscarDetailSection(oscar: oscar),

                    if (oscar.className?.toLowerCase() != 'special') ...[
                      Text(
                        'All Nominations for this Movie:',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                      ),
                      // --- SUMMARY SECTION ---
                      Consumer(
                        builder: (context, ref, _) {
                          final allOscarsAsync = ref.watch(oscarDataProvider);
                          return allOscarsAsync.when(
                            data: (allOscarsData) {
                              final nominations = allOscarsData
                                  .where(
                                    (o) =>
                                        o.film.trim().toLowerCase() ==
                                            oscar.film.trim().toLowerCase() &&
                                        o.filmId == oscar.filmId,
                                  )
                                  .toList();
                              final wins = nominations
                                  .where((n) => n.winner)
                                  .length;
                              final specialAwards = nominations
                                  .where(
                                    (n) =>
                                        n.className?.toLowerCase() == 'special',
                                  )
                                  .length;
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12.0,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,

                                  children: [
                                    SummaryChip(
                                      label: 'Nominations',
                                      count: nominations.length,
                                      color: OscarDesignTokens.info,
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
                              );
                            },
                            loading: () => const SizedBox(height: 40),
                            error: (error, stack) => const SizedBox(height: 40),
                          );
                        },
                      ),

                      // --- END SUMMARY SECTION ---
                      Consumer(
                        builder: (context, ref, _) {
                          final allOscarsAsync = ref.watch(oscarDataProvider);
                          return allOscarsAsync.when(
                            data: (allOscarsData) {
                              final nominations = allOscarsData
                                  .where(
                                    (o) =>
                                        o.film.trim().toLowerCase() ==
                                            oscar.film.trim().toLowerCase() &&
                                        o.filmId == oscar.filmId,
                                  )
                                  .toList();
                              return ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: nominations.length,
                                separatorBuilder: (_, __) => const Divider(),
                                itemBuilder: (context, index) {
                                  final nomination = nominations[index];
                                  final isOriginalSong = nomination
                                      .canonCategory
                                      .toUpperCase()
                                      .contains('ORIGINAL SONG');

                                  // Parse nominees to get all nominee info
                                  final nominees = NomineeParser.parseNominees(
                                    nomination.nominee,
                                    nomination.nomineeId,
                                  );

                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 4,
                                    ),
                                    elevation: 2,
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Category header
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  isOriginalSong
                                                      ? '${nomination.category}: ${nomination.name}'
                                                      : nomination.category,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleSmall
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.normal,
                                                      ),
                                                ),
                                              ),
                                              if (nomination.winner) Text('🏆'),
                                              const SizedBox(width: 8),
                                            ],
                                          ),
                                          const SizedBox(height: 12),

                                          // Individual nominees
                                          if (nominees.isNotEmpty) ...[
                                            Text(
                                              nominees.length == 1
                                                  ? 'Nominee:'
                                                  : 'Nominees:',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w500,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSurface
                                                        .withOpacity(0.7),
                                                  ),
                                            ),
                                            const SizedBox(height: 8),
                                            ...nominees.map((nominee) {
                                              final nomineeName =
                                                  nominee['name'] ?? 'Unknown';
                                              final nomineeId =
                                                  nominee['id'] ?? '';

                                              return Container(
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 2,
                                                    ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 6,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Theme.of(
                                                    context,
                                                  ).colorScheme.surface,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  border: Border.all(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .outline
                                                        .withOpacity(0.3),
                                                  ),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.person,
                                                      size: 18,
                                                      color: Theme.of(
                                                        context,
                                                      ).colorScheme.primary,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                      child: Text(
                                                        nomineeName,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyMedium
                                                            ?.copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    if (nomineeId.isNotEmpty)
                                                      OutlinedButton.icon(
                                                        onPressed: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  OscarPersonLookupScreen(
                                                                    initialNomineeId:
                                                                        nomineeId,
                                                                  ),
                                                            ),
                                                          );
                                                        },
                                                        icon: const Icon(
                                                          Icons.list_alt,
                                                          size: 14,
                                                        ),
                                                        label: const Text(
                                                          'View All',
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                        style: OutlinedButton.styleFrom(
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 12,
                                                                vertical: 6,
                                                              ),
                                                          minimumSize:
                                                              Size.zero,
                                                          tapTargetSize:
                                                              MaterialTapTargetSize
                                                                  .shrinkWrap,
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              );
                                            }),
                                          ] else ...[
                                            // Fallback for nominations without parsed nominees
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.person,
                                                  size: 16,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurface
                                                      .withOpacity(0.6),
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    isOriginalSong
                                                        ? 'Song nominees'
                                                        : nomination.name,
                                                    style: Theme.of(
                                                      context,
                                                    ).textTheme.bodyMedium,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            loading: () => const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(child: CircularProgressIndicator()),
                            ),
                            error: (error, stack) => const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text('No nominations found.'),
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
            // Navigation buttons are now next to the poster
          ],
        ),
      ),
    );
  }
}
