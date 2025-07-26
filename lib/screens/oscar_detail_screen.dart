import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oscars/widgets/omdb_info_box_widget.dart';
import 'package:oscars/widgets/oscar_detail_widget.dart';

import '../models/oscar_winner.dart';
import '../providers/oscar_providers.dart';
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
                                  color: Colors.grey[200],
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

                    Text(
                      'All Nominations for this Movie:',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                                      oscar.film.trim().toLowerCase(),
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
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SummaryChip(
                                    label: 'Nominations',
                                    count: nominations.length,
                                    color: Colors.blue,
                                  ),
                                  const SizedBox(width: 12),
                                  SummaryChip(
                                    label: 'Wins',
                                    count: wins,
                                    color: Colors.amber,
                                  ),
                                  const SizedBox(width: 12),
                                  SummaryChip(
                                    label: 'Special Awards',
                                    count: specialAwards,
                                    color: Colors.green,
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
                                      oscar.film.trim().toLowerCase(),
                                )
                                .toList();
                            return ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: nominations.length,
                              separatorBuilder: (_, __) => const Divider(),
                              itemBuilder: (context, index) {
                                final nomination = nominations[index];
                                final isOriginalSong = nomination.canonCategory
                                    .toUpperCase()
                                    .contains('ORIGINAL SONG');
                                return ListTile(
                                  title: isOriginalSong
                                      ? Text(
                                          '${nomination.category}: ${nomination.name}',
                                        )
                                      : Text(nomination.category),
                                  subtitle: isOriginalSong
                                      ? null
                                      : Text(nomination.name),
                                  trailing: nomination.winner
                                      ? const Icon(
                                          Icons.emoji_events,
                                          color: Colors.amber,
                                        )
                                      : null,
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
