import 'package:oscars/services/database_service.dart';

void main() async {
  final db = DatabaseService.instance;
  final nominees = db.getAllNominees();
  print('Total nominees in database: ${nominees.length}');
  if (nominees.isNotEmpty) {
    print('First few nominees:');
    for (int i = 0; i < (nominees.length > 5 ? 5 : nominees.length); i++) {
      final n = nominees[i];
      print('  ${n.name} (ID: ${n.nomineeId})');
    }
  }
}
