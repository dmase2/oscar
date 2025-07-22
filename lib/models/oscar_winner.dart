import 'package:objectbox/objectbox.dart';

@Entity()
class OscarWinner {
  @Id()
  int id = 0;

  int yearFilm;
  int yearCeremony;
  int ceremony;
  String category;
  String canonCategory;
  String name;
  String film;
  String filmId;
  String nominee;
  String nomineeId;
  bool winner;
  String detail;
  String note;
  String citation;
  String? className;

  double? domesticBoxOffice;
  double? foreignBoxOffice;
  double? totalBoxOffice;
  int? rottenTomatoesScore;

  OscarWinner({
    required this.yearFilm,
    required this.yearCeremony,
    required this.ceremony,
    required this.category,
    required this.canonCategory,
    required this.name,
    required this.film,
    required this.filmId,
    required this.nominee,
    required this.nomineeId,
    required this.winner,
    required this.detail,
    required this.note,
    required this.citation,
    this.domesticBoxOffice,
    this.foreignBoxOffice,
    this.totalBoxOffice,
    this.rottenTomatoesScore,
    this.className,
  });
}
