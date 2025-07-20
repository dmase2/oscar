import 'package:flutter/material.dart';
import '../models/oscar_nominee.dart';
import '../screens/oscar_nominee_detail_screen.dart';

class OscarNomineeCard extends StatelessWidget {
  final OscarNominee nominee;
  final List<OscarNominee>? allNominees;
  final int? currentIndex;

  const OscarNomineeCard({
    super.key,
    required this.nominee,
    this.allNominees,
    this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OscarNomineeDetailScreen(
                nominee: nominee,
                allNominees: allNominees,
                currentIndex: currentIndex,
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                  color: Colors.grey[200],
                ),
                child: Center(
                  child: Text(
                    nominee.film,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nominee.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(nominee.category),
                  Text(nominee.year),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
