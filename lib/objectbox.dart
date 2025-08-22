import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'models/box_office_entry.dart';
import 'objectbox.g.dart'; // generated code

/// Manages ObjectBox store and boxes.
class ObjectBox {
  // Singleton instance to prevent multiple stores
  static ObjectBox? _instance;

  /// The ObjectBox store.
  late final Store store;

  /// Box for BoxOfficeEntry objects.
  late final Box<BoxOfficeEntry> boxOfficeEntryBox;

  ObjectBox._create(this.store) {
    boxOfficeEntryBox = store.box<BoxOfficeEntry>();
  }

  /// Initializes (or returns existing) ObjectBox store singleton.
  static Future<ObjectBox> create() async {
    if (_instance != null) {
      return _instance!;
    }
    // Use a separate directory for BoxOffice store
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final boxOfficeDir = Directory('${documentsDirectory.path}/boxoffice_data');
    if (!await boxOfficeDir.exists()) {
      await boxOfficeDir.create(recursive: true);
    }
    final store = await openStore(directory: boxOfficeDir.path);
    _instance = ObjectBox._create(store);
    return _instance!;
  }
}
