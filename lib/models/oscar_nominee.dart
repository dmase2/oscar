import 'package:objectbox/objectbox.dart';

@Entity()
class OscarNominee {
  @Id()
  int id = 0;

  int ceremony;
  String year;
  String className;
  String canonicalCategory;
  String category;
  String film;
  String filmId;
  String name;
  String nominees;
  String nomineeIds;
  bool winner;
  String detail;
  String note;
  String citation;

  OscarNominee({
    required this.ceremony,
    required this.year,
    required this.className,
    required this.canonicalCategory,
    required this.category,
    required this.film,
    required this.filmId,
    required this.name,
    required this.nominees,
    required this.nomineeIds,
    required this.winner,
    required this.detail,
    required this.note,
    required this.citation,
  });
}
