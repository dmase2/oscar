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
  bool winner;

  double? domesticBoxOffice;
  double? foreignBoxOffice;
  double? totalBoxOffice;

  OscarWinner({
    required this.yearFilm,
    required this.yearCeremony,
    required this.ceremony,
    required this.category,
    required this.canonCategory,
    required this.name,
    required this.film,
    required this.winner,
    this.domesticBoxOffice,
    this.foreignBoxOffice,
    this.totalBoxOffice,
  });
}
