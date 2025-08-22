import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/oscar_providers.dart';
import '../screens/movie_lookup_screen.dart';
import '../screens/oscar_person_lookup_screen.dart';

class OscarsAppDrawer extends StatelessWidget {
  final String? selected;
  const OscarsAppDrawer({super.key, this.selected});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Expanded(
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
                  title: const Text('Movie Lookup'),
                  leading: Icon(Icons.movie),
                  selected: selected == 'movie_lookup',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MovieLookupScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  title: const Text('Statistics'),
                  leading: const Icon(Icons.bar_chart),
                  selected: selected == 'statistics',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, '/statistics');
                  },
                ),
                ListTile(
                  title: const Text('Actor Revenue Lookup'),
                  leading: const Icon(Icons.attach_money),
                  selected: selected == 'actor_revenue',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, '/actor_revenue');
                  },
                ),
                ListTile(
                  title: const Text('Nominee ID Lookup'),
                  leading: const Icon(Icons.person_search),
                  selected: selected == 'nominee_lookup',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, '/nominee_lookup');
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
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: _LearnModeSwitch(),
          ),
        ],
      ),
    );
  }
}

// Learn Mode switch widget for the drawer
class _LearnModeSwitch extends ConsumerWidget {
  const _LearnModeSwitch();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final learnMode = ref.watch(learnModeProvider);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Learn Mode', style: TextStyle(fontSize: 16)),
        Switch(
          value: learnMode,
          onChanged: (value) {
            ref.read(learnModeProvider.notifier).state = value;
          },
        ),
      ],
    );
  }
}
