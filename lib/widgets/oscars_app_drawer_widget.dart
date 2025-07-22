import 'package:flutter/material.dart';

import '../screens/oscar_person_lookup_screen.dart';

class OscarsAppDrawer extends StatelessWidget {
  final String? selected;
  const OscarsAppDrawer({super.key, this.selected});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          ListTile(
            title: const Text('Oscars Home'),
            leading: const Icon(Icons.home),
            selected: selected == 'Oscars',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/');
            },
          ),

          ListTile(
            title: const Text('Nominee Lookup'),
            leading: const Icon(Icons.search),
            selected: selected == 'lookup',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const OscarPersonLookupScreen(),
                ),
              );
            },
          ),
          ListTile(
            title: const Text('Settings'),
            leading: const Icon(Icons.settings),
            selected: selected == 'settings',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/settings');
            },
          ),
        ],
      ),
    );
  }
}
