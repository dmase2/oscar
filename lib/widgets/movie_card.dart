import 'package:flutter/material.dart';
import '../models/oscar_winner.dart';
import 'poster_image_widget.dart';
import '../screens/movie_detail_screen.dart';

class MovieCard extends StatelessWidget {
  final OscarWinner oscar;
  final List<OscarWinner>? allOscars;
  final int? currentIndex;

  const MovieCard({super.key, required this.oscar, this.allOscars, this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MovieDetailScreen(
                oscar: oscar,
                allOscars: allOscars,
                currentIndex: currentIndex,
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Hero(
                tag: 'poster_${oscar.film}_${oscar.yearFilm}_${oscar.name}_${oscar.hashCode}',
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4),
                    ),
                    color: Colors.grey[200],
                  ),
                  child: PosterImageWidget(oscar: oscar),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    oscar.film,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${oscar.yearFilm}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    oscar.name,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      fontSize: 10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
