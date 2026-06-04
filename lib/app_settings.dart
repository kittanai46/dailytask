import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

final ValueNotifier<ThemeMode> appThemeMode = ValueNotifier(ThemeMode.light);

Future<void> loadThemeMode() async {
  final prefs = await SharedPreferences.getInstance();
  final saved = prefs.getString('theme_mode') ?? 'light';
  if (saved == 'dark') {
    appThemeMode.value = ThemeMode.dark;
  } else if (saved == 'system') {
    appThemeMode.value = ThemeMode.system;
  } else {
    appThemeMode.value = ThemeMode.light;
  }
}

Future<void> saveThemeMode(ThemeMode mode) async {
  final prefs = await SharedPreferences.getInstance();
  String val;
  switch (mode) {
    case ThemeMode.dark:
      val = 'dark';
      break;
    case ThemeMode.system:
      val = 'system';
      break;
    default:
      val = 'light';
  }
  await prefs.setString('theme_mode', val);
  appThemeMode.value = mode;
}
