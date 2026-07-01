import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

const themeModePreferenceKey = 'theme_mode';

Future<ThemeMode> loadPersistedThemeMode() async {
  final prefs = await SharedPreferences.getInstance();
  return themeModeFromPreference(prefs.getString(themeModePreferenceKey));
}

Future<void> saveThemeMode(ThemeMode mode) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(themeModePreferenceKey, themeModeToPreference(mode));
}

ThemeMode themeModeFromPreference(String? value) {
  return switch (value) {
    'light' => ThemeMode.light,
    'system' => ThemeMode.system,
    _ => ThemeMode.dark,
  };
}

String themeModeToPreference(ThemeMode mode) {
  return switch (mode) {
    ThemeMode.light => 'light',
    ThemeMode.dark => 'dark',
    ThemeMode.system => 'system',
  };
}

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.dark);
