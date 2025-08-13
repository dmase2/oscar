import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/oscar_winner.dart';
import '../providers/oscar_providers.dart';
import '../providers/shade_opacity_provider.dart';
import '../screens/oscar_detail_screen.dart';
import '../utils/oscar_utils.dart';
import '../widgets/poster_image_widget.dart';

class MovieCard extends StatefulWidget {
  final OscarWinner oscar;
  final List<OscarWinner>? allOscars;
  final int? currentIndex;
  final Object? filterKey;

  const MovieCard({
    super.key,
    required this.oscar,
    this.allOscars,
    this.currentIndex,
    this.filterKey,
  });

  @override
  State<MovieCard> createState() => _MovieCardState();
}

class _MovieCardState extends State<MovieCard> {
  bool _revealed = false;
  Object? _lastFilterKey;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final learnMode = ref.watch(learnModeProvider);
        final shadeOpacity = ref.watch(shadeOpacityProvider);
        // Reset shade if filterKey changes and learnMode is true
        if (learnMode) {
          if (_lastFilterKey != widget.filterKey) {
            _revealed = false;
            _lastFilterKey = widget.filterKey;
          }
        }
        if (learnMode && !_revealed) {
          return Stack(
            children: [
              Opacity(opacity: 0.2, child: _buildCard(context)),
              Positioned.fill(
                child: Material(
                  color: Colors.black.withOpacity(shadeOpacity),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _revealed = true;
                      });
                    },
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            '${widget.oscar.yearFilm}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            widget.oscar.film.substring(0, 1),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 48,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        } else {
          return _buildCard(context);
        }
      },
    );
  }

  Widget _buildCard(BuildContext context) {
    final oscar = widget.oscar;
    final allOscars = widget.allOscars;
    final currentIndex = widget.currentIndex;
    final isWinner = oscar.winner == true;
    return Card(
      elevation: isWinner ? 10 : 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: isWinner
            ? const BorderSide(
                color: Color.fromARGB(255, 190, 140, 2),
                width: 3,
              ) // Gold
            : BorderSide.none,
      ),
      shadowColor: isWinner
          ? const Color.fromARGB(255, 198, 162, 4)
          : Colors.black,
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
                tag:
                    'poster_${oscar.film}_${oscar.yearFilm}_${oscar.name}_${oscar.hashCode}',
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Tooltip(
                      message: 'Click for Details',
                      child: Container(
                        width: double.infinity,
                        color: Colors.grey[200],
                        child: SizedBox.expand(
                          child: PosterImageWidget(oscar: oscar),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    OscarUtils.getCardTitle(oscar),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${oscar.yearFilm}  ${oscar.winner ? '🏆' : ''}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.black,
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    OscarUtils.shouldShowSongDetail(oscar)
                        ? '${oscar.detail} - ${oscar.name}'
                        : oscar.name,
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
