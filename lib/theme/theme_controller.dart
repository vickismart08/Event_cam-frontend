import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kThemeModeKey = 'glamora_theme_mode';

/// Persisted light / dark / system theme toggle.
/// Access via the global [themeController] singleton.
final ThemeController themeController = ThemeController();

class ThemeController extends ChangeNotifier {
  // Default to light — never follows the OS setting unless the user explicitly toggles.
  ThemeMode _mode = ThemeMode.light;

  ThemeMode get mode => _mode;

  bool get isDark => _mode == ThemeMode.dark;

  /// Call once at startup. Defaults to light if no preference has been saved yet.
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(_kThemeModeKey);
      _mode = switch (stored) {
        'dark' => ThemeMode.dark,
        // 'light' or null (first launch) both resolve to light.
        _ => ThemeMode.light,
      };
      notifyListeners();
    } catch (_) {
      // Plugin not yet available (e.g. first web run before rebuild). Stay light.
      _mode = ThemeMode.light;
    }
  }

  Future<void> setMode(ThemeMode mode) async {
    if (_mode == mode) return;
    _mode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kThemeModeKey, switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      _ => 'system',
    });
  }

  void toggle() {
    final next = _mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    setMode(next);
  }
}
