
import 'package:material_ui/material_ui.dart';
import 'preferences_service.dart';

class ThemeController {
  ThemeController._();

  static final ThemeController instance = ThemeController._();

  final PreferencesService _storage = PreferencesService();

  final ValueNotifier<ThemeMode> themeMode =
      ValueNotifier(ThemeMode.light);

  // Load saved theme when app starts
  Future<void> loadTheme() async {
    final savedTheme = await _storage.getString('theme');

    themeMode.value = savedTheme == 'dark'
        ? ThemeMode.dark
        : ThemeMode.light;
  }

  // Change theme and save it
  Future<void> setDarkMode(bool isDark) async {
    themeMode.value =
        isDark ? ThemeMode.dark : ThemeMode.light;

    await _storage.saveString(
      'theme',
      isDark ? 'dark' : 'light',
    );
  }
}
