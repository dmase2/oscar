import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'design_system/design_system.dart';
import 'design_system/examples/design_system_example.dart';
import 'screens/actor_revenue_screen.dart';
import 'screens/nominee_lookup_screen.dart';
import 'screens/oscars_home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/statistics_screen.dart';
import 'services/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService.instance.initialize();
  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Oscar Winners',
      theme: OscarTheme.lightTheme,
      darkTheme: OscarTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/statistics': (context) => const StatisticsScreen(),
        '/actor_revenue': (context) => const ActorRevenueScreen(),
        '/nominee_lookup': (context) => const NomineeLookupScreen(),
        '/design_system': (context) => const DesignSystemExample(),
      },
    );
  }
}
