import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final shadeOpacityProvider =
    StateNotifierProvider<ShadeOpacityNotifier, double>(
      (ref) => ShadeOpacityNotifier(),
    );

class ShadeOpacityNotifier extends StateNotifier<double> {
  static const String _key = 'shade_opacity';
  static const double _defaultOpacity = 0.5;

  ShadeOpacityNotifier() : super(_defaultOpacity) {
    _loadOpacity();
  }

  Future<void> _loadOpacity() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getDouble(_key) ?? _defaultOpacity;
  }

  Future<void> setOpacity(double value) async {
    state = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_key, value);
  }
}
