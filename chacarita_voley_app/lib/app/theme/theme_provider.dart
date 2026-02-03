import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey =
      'theme_mode_v2'; // Cambiado para evitar conflicto con valor antiguo
  static const String _oldThemeKey = 'theme_mode'; // Key antigua
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadThemeFromPrefs();
  }

  Future<void> _loadThemeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    // Limpiar valor antiguo si existe
    if (prefs.containsKey(_oldThemeKey)) {
      await prefs.remove(_oldThemeKey);
      print('🗑️ Limpiado valor antiguo de tema');
    }

    if (!prefs.containsKey(_themeKey)) {
      _themeMode = ThemeMode.system;
      print('🎨 Usando tema del sistema por defecto');
    } else {
      final themeValue = prefs.getString(_themeKey);
      _themeMode = _themeModeFromString(themeValue);
      print('🎨 Tema cargado: $_themeMode');
    }
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode.name);
  }

  Future<void> toggleTheme(bool isDark) async {
    await setThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
  }

  ThemeMode _themeModeFromString(String? value) {
    switch (value) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isSystemMode => _themeMode == ThemeMode.system;
}
