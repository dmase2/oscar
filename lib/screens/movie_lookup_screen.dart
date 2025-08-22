import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:oscars/models/box_office_entry.dart';
import 'package:oscars/models/poster_cache_entry.dart';
import 'package:oscars/services/box_office_service.dart';
import 'package:oscars/services/database_service.dart';
import 'package:oscars/services/omdb_service_extra.dart';
import 'package:oscars/services/poster_service.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/oscars_app_drawer_widget.dart';

class MovieLookupScreen extends StatefulWidget {
  const MovieLookupScreen({super.key});

  @override
  State<MovieLookupScreen> createState() => _MovieLookupScreenState();
}

class _MovieLookupScreenState extends State<MovieLookupScreen> {
  final TextEditingController _controller = TextEditingController();
  BoxOfficeEntry? _selectedEntry;

  // Try to read a cached year from PosterCacheEntry.cacheKey which uses format '<film>_<year>'
  int? _getCachedYearForTitle(String title) {
    try {
      final posterBox = DatabaseService.instance.store.box<PosterCacheEntry>();
      final cached = posterBox.getAll();
      for (final p in cached) {
        final key = p.cacheKey;
        if (key.startsWith('${title}_')) {
          final parts = key.split('_');
          if (parts.length >= 2) {
            final maybeYear = int.tryParse(parts.last);
            if (maybeYear != null && maybeYear > 0) return maybeYear;
          }
        }
      }
    } catch (e) {
      // ignore DB errors and fall back to OMDb
    }
    return null;
  }

  // Fetch year from OMDb (id-first, then title fallback). Returns null if unknown.
  Future<int?> _fetchYearFromOmdb(BoxOfficeEntry entry) async {
    try {
      final imdbId = 'tt${entry.id}';
      OmdbExtraInfo? info = await OmdbServiceExtra.fetchExtraInfo(imdbId);
      if (info == null || (info.year == null || info.year!.isEmpty)) {
        // Fallback to title-based lookup without a year constraint
        info = await OmdbServiceExtra.fetchExtraInfoByTitle(entry.title, 0);
      }
      if (info?.year != null && info!.year!.isNotEmpty) {
        final m = RegExp(r"(\d{4})").firstMatch(info.year!);
        if (m != null) return int.tryParse(m.group(1)!);
      }
    } catch (e) {
      // ignore network/parse errors
    }
    return null;
  }

  Future<List<BoxOfficeEntry>> _searchMovies(String pattern) async {
    final svc = BoxOfficeService.instance;
    final all = svc.getAllBoxOfficeEntries();
    final lower = pattern.toLowerCase();
    final filtered = all
        .where((e) => e.title.toLowerCase().contains(lower))
        .toList();
    filtered.sort((a, b) => a.title.compareTo(b.title));
    return filtered;
  }

  String _formatMoney(int v) {
    return v == 0
        ? '\$0'
        : '\$${v.toString().replaceAllMapped(RegExp(r"\B(?=(\d{3})+(?!\d))"), (m) => ',')}';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildDetail(BoxOfficeEntry entry) {
    Future<Map<String, dynamic>> loadPosterAndYear() async {
      // Prefer cached year from PosterCache
      int? year = _getCachedYearForTitle(entry.title);
      final imdbId = 'tt${entry.id}';
      String? director;

      if (year == null || year == 0) {
        // Fall back to OMDb lookup if we don't have a cached year
        OmdbExtraInfo? info = await OmdbServiceExtra.fetchExtraInfo(imdbId);
        if (info == null || info.year == null || info.year!.isEmpty) {
          info = await OmdbServiceExtra.fetchExtraInfoByTitle(entry.title, 0);
        }
        if (info != null) {
          if (info.year != null) {
            final m = RegExp(r"(\d{4})").firstMatch(info.year!);
            if (m != null) year = int.tryParse(m.group(1)!);
          }
          if (info.director != null && info.director!.toLowerCase() != 'n/a') {
            director = info.director;
          }
        }
      }

      final posterUrl = await PosterService.getPosterUrl(
        entry.title,
        year ?? 0,
        imdbId,
      );
      return {'posterUrl': posterUrl, 'year': year, 'director': director};
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            FutureBuilder<Map<String, dynamic>>(
              future: loadPosterAndYear(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    width: 120,
                    height: 180,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final data = snapshot.data ?? {};
                final posterUrl = data['posterUrl'] as String?;
                final year = data['year'] as int?;
                final director = data['director'] as String?;

                return Row(
                  children: [
                    if (posterUrl != null)
                      Image.network(
                        posterUrl,
                        width: 120,
                        height: 180,
                        fit: BoxFit.cover,
                      )
                    else
                      Container(
                        width: 120,
                        height: 180,
                        color: Theme.of(context).colorScheme.surface,
                      ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.title,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        if (year != null) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.tertiary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '$year',
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        if (director != null) Text('Director: $director'),
                        const SizedBox(height: 8),
                        // Show full box office breakdown
                        Text('Domestic: ${_formatMoney(entry.domestic)}'),
                        const SizedBox(height: 6),
                        Text(
                          'International: ${_formatMoney(entry.international)}',
                        ),
                        const SizedBox(height: 6),
                        Text('Worldwide: ${_formatMoney(entry.worldwide)}'),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () async {
                            try {
                              var raw = entry.url.trim();
                              if (raw.isEmpty) throw 'No URL available';
                              // Ensure URL has a scheme
                              if (!raw.startsWith(RegExp(r'https?://'))) {
                                raw = 'https://$raw';
                              }
                              final uri = Uri.tryParse(raw);
                              if (uri == null) throw 'Invalid URL';

                              // Prefer opening externally
                              final opened = await launchUrl(
                                uri,
                                mode: LaunchMode.externalApplication,
                              );
                              if (!opened) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Could not open link'),
                                    ),
                                  );
                                }
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Could not open link: $e'),
                                  ),
                                );
                              }
                            }
                          },
                          child: const Text('Open Box Office Page'),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Movie Lookup')),
      drawer: const OscarsAppDrawer(selected: 'movie_lookup'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TypeAheadField<BoxOfficeEntry>(
              suggestionsCallback: _searchMovies,
              builder:
                  (
                    context,
                    TextEditingController controller,
                    FocusNode focusNode,
                  ) {
                    return TextField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: const InputDecoration(
                        labelText: 'Search movie',
                        border: OutlineInputBorder(),
                      ),
                    );
                  },
              itemBuilder: (context, suggestion) {
                // Prefer cached year from PosterCache; if missing, fallback to OMDb lookup
                final cachedYear = _getCachedYearForTitle(suggestion.title);
                Widget? trailing;
                if (cachedYear != null && cachedYear > 0) {
                  trailing = Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.tertiary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '$cachedYear',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                } else {
                  trailing = FutureBuilder<int?>(
                    future: _fetchYearFromOmdb(suggestion),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return SizedBox(
                          width: 36,
                          child: Center(
                            child: SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        );
                      }
                      final y = snapshot.data;
                      if (y != null && y > 0) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.tertiary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '$y',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  );
                }

                return ListTile(
                  title: Text(suggestion.title),
                  subtitle: Text(
                    'Worldwide: ${_formatMoney(suggestion.worldwide)}',
                  ),
                  // Do NOT handle onTap here; let TypeAheadField's onSelected handle the selection
                  trailing: trailing,
                );
              },
              onSelected: (suggestion) {
                setState(() {
                  _selectedEntry = suggestion;
                  // sync the field controller we use elsewhere
                  _controller.text = suggestion.title;
                });
                // Close the keyboard / suggestions
                FocusScope.of(context).unfocus();
              },
              emptyBuilder: (context) =>
                  const ListTile(title: Text('No movie found')),
            ),
            if (_selectedEntry != null) _buildDetail(_selectedEntry!),
            const SizedBox(height: 12),
            Expanded(
              child: FutureBuilder<List<BoxOfficeEntry>>(
                future: _searchMovies(_controller.text),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final items = snapshot.data ?? [];
                  return ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, idx) {
                      final e = items[idx];
                      return ListTile(
                        title: Text(e.title),
                        subtitle: Text(
                          'Worldwide: ${_formatMoney(e.worldwide)}',
                        ),
                        onTap: () => setState(() => _selectedEntry = e),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
