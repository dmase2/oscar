import 'package:objectbox/objectbox.dart';

@Entity()
class Nominee {
  @Id()
  int id = 0;

  String name;
  String nomineeId;
  String filmIdsString;

  // Audit trail fields
  @Property(type: PropertyType.date)
  DateTime? createdAt;
  @Property(type: PropertyType.date)
  DateTime? updatedAt;
  String? createdBy;
  String? updatedBy;

  Nominee({
    required this.name,
    required this.nomineeId,
    required List<String> filmIds,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.updatedBy,
  }) : filmIdsString = filmIds.join('|') {
    createdAt ??= DateTime.now();
    updatedAt ??= DateTime.now();
    createdBy ??= 'system';
    updatedBy ??= 'system';
  }

  List<String> get filmIds =>
      filmIdsString.split('|').where((f) => f.isNotEmpty).toList();

  void updateAuditTrail({String? updatedBy}) {
    updatedAt = DateTime.now();
    this.updatedBy = updatedBy ?? 'system';
  }
}
