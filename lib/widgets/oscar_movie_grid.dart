import 'package:flutter/material.dart';
import '../models/oscar_winner.dart';
import 'movie_card.dart';

class OscarMovieGrid extends StatelessWidget {
  final List<OscarWinner> oscars;

  const OscarMovieGrid({super.key, required this.oscars});

  @override
  Widget build(BuildContext context) {
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
        );
      },
    );
  }
}
