import 'dart:io';

import 'package:oscars/services/database_service.dart';

void main() async {
  try {
    print("Starting simple database clear test...");

    // Initialize the database service
    final dbService = DatabaseService.instance;
    await dbService.initialize();
    print("Database service initialized");

    // Count initial records
    final initialOscarCount = dbService.getAllOscarWinners().length;
    final initialNomineeCount = dbService.getAllNominees().length;
    print("Initial Oscar winners: $initialOscarCount");
    print("Initial nominees: $initialNomineeCount");

    if (initialOscarCount == 0 && initialNomineeCount == 0) {
      print(
        "Database is already empty - test will just verify clearing works.",
      );
    }

    // Clear the database using the existing clear methods
    print("\nClearing database...");
    // Note: There's no clearOscarWinners method, so we need to use the box directly
    dbService.oscarBox.removeAll();
    await dbService.clearNominees();

    // Count after clearing
    final finalOscarCount = dbService.getAllOscarWinners().length;
    final finalNomineeCount = dbService.getAllNominees().length;
    print("After clearing - Oscar winners: $finalOscarCount");
    print("After clearing - nominees: $finalNomineeCount");

    // Verify clearing worked
    if (finalOscarCount == 0 && finalNomineeCount == 0) {
      print("\n✅ SUCCESS: Both tables were cleared successfully!");
      print("The fix in settings_screen.dart should now work correctly!");
    } else {
      print("\n❌ ERROR: Tables were not fully cleared");
      print("Oscar winners remaining: $finalOscarCount");
      print("Nominees remaining: $finalNomineeCount");
    }
  } catch (e) {
    print("❌ ERROR: $e");
    exit(1);
  }

  exit(0);
}
