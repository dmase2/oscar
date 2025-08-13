import 'dart:io';

import 'package:oscars/services/database_service.dart';

void main() async {
  try {
    final db = DatabaseService.instance;
    await db.initialize();

    // Check initial state
    final initialOscarWinners = db.getAllOscarWinners();
    final initialNominees = db.getAllNominees();

    print('Before clearing:');
    print('  Oscar Winners: ${initialOscarWinners.length}');
    print('  Nominees: ${initialNominees.length}');

    // Clear both tables (simulate settings screen clear database)
    db.oscarBox.removeAll();
    await db.clearNominees();

    // Check after clearing
    final clearedOscarWinners = db.getAllOscarWinners();
    final clearedNominees = db.getAllNominees();

    print('After clearing:');
    print('  Oscar Winners: ${clearedOscarWinners.length}');
    print('  Nominees: ${clearedNominees.length}');

    if (clearedOscarWinners.isEmpty && clearedNominees.isEmpty) {
      print('✅ Clear database functionality working correctly!');
    } else {
      print('❌ Clear database functionality not working properly!');
    }
  } catch (e) {
    print('❌ Error: $e');
    exit(1);
  }
}
