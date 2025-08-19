import 'dart:io' show Platform, exit;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oscars/services/build_oscar_winner.dart';

import '../design_system/design_system.dart';
import '../models/oscar_winner.dart';
import '../providers/oscar_providers.dart';
import '../providers/shade_opacity_provider.dart';
import '../widgets/oscars_app_drawer_widget.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _clearDatabase(BuildContext context, WidgetRef ref) async {
    final dbService = ref.read(databaseServiceProvider);
    dbService.oscarBox.removeAll();
    
    // Trigger provider refresh using the helper
    ref.read(refreshOscarDataProvider)();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'ObjectBox database cleared.',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onInverseSurface,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.inverseSurface,
      ),
    );
  }

  Future<void> _reloadDatabase(BuildContext context, WidgetRef ref) async {
    final dbService = ref.read(databaseServiceProvider);
    dbService.oscarBox.removeAll();
    final List<OscarWinner> winners =
        await OscarWinnerFromNomineeCsvService.loadOscarWinnersFromNomineeCsv();
    await dbService.insertOscarWinners(winners);
    
    // Trigger provider refresh using the helper
    ref.read(refreshOscarDataProvider)();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Reloaded ${winners.length} records from CSV.',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onInverseSurface,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.inverseSurface,
      ),
    );
  }

  Future<void> _exitApplication(BuildContext context) async {
    // Show confirmation dialog
    final bool? shouldExit = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Exit Application'),
          content: const Text('Are you sure you want to exit the application?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Exit'),
            ),
          ],
        );
      },
    );

    if (shouldExit == true) {
      if (!kIsWeb) {
        // For mobile and desktop platforms
        if (Platform.isIOS) {
          // iOS doesn't allow programmatic app termination
          // Show a message explaining this limitation
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'iOS does not allow apps to exit programmatically. Please use the home button or app switcher.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onInverseSurface,
                  ),
                ),
                backgroundColor: Theme.of(context).colorScheme.inverseSurface,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        } else if (Platform.isAndroid) {
          // Android - use SystemNavigator.pop()
          SystemNavigator.pop();
        } else if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
          // Desktop platforms - exit the application
          exit(0);
        } else {
          // Fallback for other platforms
          SystemNavigator.pop();
        }
      } else {
        // Web platform - just close the tab/window (limited by browser)
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Please close the browser tab to exit.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onInverseSurface,
                ),
              ),
              backgroundColor: Theme.of(context).colorScheme.inverseSurface,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      drawer: const OscarsAppDrawer(selected: 'settings'),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            // Persistent slider for shade opacity in learning mode
            Text(
              'Learning Mode Shade Opacity',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            OscarSpacing.space2,
            Consumer(
              builder: (context, ref, _) {
                final opacity = ref.watch(shadeOpacityProvider);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Slider(
                      value: opacity,
                      min: 0.1,
                      max: 1.0,
                      divisions: 18,
                      label: opacity.toStringAsFixed(2),
                      onChanged: (value) {
                        ref
                            .read(shadeOpacityProvider.notifier)
                            .setOpacity(value);
                      },
                    ),
                    Text('Current: ${(opacity * 100).toStringAsFixed(0)}%'),
                  ],
                );
              },
            ),
            const Divider(height: 32),
            // Design System Demo Link
            OscarButton(
              text: 'Design System Demo',
              onPressed: () {
                Navigator.pushNamed(context, '/design_system');
              },
              variant: OscarButtonVariant.secondary,
              isFullWidth: true,
            ),
            OscarSpacing.space4,
            OscarButton(
              text: 'Clear ObjectBox Database',
              onPressed: () => _clearDatabase(context, ref),
              variant: OscarButtonVariant.secondary,
              isFullWidth: true,
            ),
            OscarSpacing.space4,
            OscarButton(
              text: 'Reload Database from CSV',
              onPressed: () => _reloadDatabase(context, ref),
              variant: OscarButtonVariant.primary,
              isFullWidth: true,
            ),
            OscarSpacing.space4,
            OscarButton(
              text: 'Print ObjectBox Database',
              onPressed: () {
                final dbService = ref.read(databaseServiceProvider);
                dbService.getAllOscarWinners();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Printed ObjectBox records to console.',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onInverseSurface,
                      ),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.inverseSurface,
                  ),
                );
              },
              variant: OscarButtonVariant.secondary,
              isFullWidth: true,
            ),
            OscarSpacing.space4,
            OscarButton(
              text: 'Exit Application',
              onPressed: () => _exitApplication(context),
              variant: OscarButtonVariant.filled,
              isFullWidth: true,
            ),
          ],
        ),
      ),
    );
  }
}
