import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oscars/widgets/omdb_info_box.dart';

import '../models/oscar_winner.dart';
import '../providers/oscar_providers.dart';
import '../services/omdb_service.dart';
import '../widgets/poster_image_widget.dart';
import '../services/database_service.dart';

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
                                child: PosterImageWidget(oscar: oscar),
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

                    Text(
                      oscar.film,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold, fontSize: 22),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow(context, 'Year', oscar.yearFilm.toString()),
                    _buildDetailRow(context, 'Category', oscar.category),
                    if (oscar.category != oscar.canonCategory)
                      _buildDetailRow(
                        context,
                        'Canon Category',
                        oscar.canonCategory,
                      ),
                    _buildDetailRow(context, 'Name', oscar.name),
                    GestureDetector(
                      onTap: () async {
                        if (oscar.nomineeId.isEmpty) return;
                        final dbService = DatabaseService.instance;
                        final movies = dbService
                            .getAllOscarWinners()
                            .where((w) => w.nomineeId == oscar.nomineeId)
                            .toList();
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Movies for ${oscar.nominee}'),
                            content: SizedBox(
                              width: 300,
                              height: 400,
                              child: ListView.builder(
                                itemCount: movies.length,
                                itemBuilder: (context, idx) {
                                  final m = movies[idx];
                                  return ListTile(
                                    title: Text(m.film),
                                    subtitle: Text('${m.yearFilm} - ${m.category}'),
                                  );
                                },
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Close'),
                              ),
                            ],
                          ),
                        );
                      },
                      child: _buildDetailRow(context, 'Nominee', oscar.nominee),
                    ),
                    _buildDetailRow(
                      context,
                      'Winner',
                      oscar.winner ? 'Yes' : 'No',
                    ),

                    FutureBuilder<int?>(
                      future: oscar.filmId.isNotEmpty
                          ? OmdbService.fetchRottenTomatoesScore(oscar.filmId)
                          : null,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 120,
                                  child: Text(
                                    'Rotten Tomatoes:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                CircularProgressIndicator(),
                              ],
                            ),
                          );
                        } else if (snapshot.hasData && snapshot.data != null) {
                          final score = snapshot.data!;
                          String emoji = score >= 60 ? '🍅' : '🤢';
                          return _buildDetailRow(
                            context,
                            'Rotten Tomatoes',
                            '$emoji $score%',
                          );
                        } else {
                          return _buildDetailRow(
                            context,
                            'Rotten Tomatoes',
                            '🟦 N/A',
                          );
                        }
                      },
                    ),
                    OmdbInfoBox(oscar: oscar),
                    const SizedBox(height: 24),

                    Text(
                      'All Nominations for this Movie:',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
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

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
