import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/box_office_entry.dart';
import '../services/box_office_service.dart';

/// Provides all BoxOfficeEntry records from the database via BoxOfficeService.
final allBoxOfficeEntriesProvider = FutureProvider<List<BoxOfficeEntry>>((
  ref,
) async {
  // Use the service to get all box office entries
  return BoxOfficeService.instance.getAllBoxOfficeEntries();
});

/// Provides a specific BoxOfficeEntry by IMDb ID.
final boxOfficeEntryByIdProvider = Provider.family<BoxOfficeEntry?, int>((
  ref,
  imdbId,
) {
  return BoxOfficeService.instance.getBoxOfficeEntryById(imdbId);
});

/// Provides BoxOfficeEntry records for a specific title (case-insensitive).
final boxOfficeEntriesByTitleProvider =
    Provider.family<List<BoxOfficeEntry>, String>((ref, title) {
      return BoxOfficeService.instance.getBoxOfficeEntriesByTitle(title);
    });

/// Provides the count of box office entries in the database.
final boxOfficeEntryCountProvider = Provider<int>((ref) {
  return BoxOfficeService.instance.getBoxOfficeEntryCount();
});
