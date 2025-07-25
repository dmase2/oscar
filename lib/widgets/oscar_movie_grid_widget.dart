import 'package:flutter/material.dart';

import '../models/oscar_winner.dart';
import 'movie_card_widget.dart';

class OscarMovieGrid extends StatelessWidget {
  final List<OscarWinner> oscars;

  const OscarMovieGrid({super.key, required this.oscars});

  @override
  Widget build(BuildContext context) {
    // Use InheritedWidget or pass filterKey from parent for more complex cases
    // For now, just use a hash of the oscars list and index for uniqueness
    final filterKey = oscars.isNotEmpty
        ? '${oscars.first.canonCategory}_${oscars.first.yearFilm}_${oscars.length}'
        : '';
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: oscars.length,
      itemBuilder: (context, index) {
        final oscar = oscars[index];
        return MovieCard(
          oscar: oscar,
          allOscars: oscars,
          currentIndex: index,
          filterKey: filterKey,
        );
      },
    );
  }
}
