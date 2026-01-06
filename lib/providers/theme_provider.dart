import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_themes.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'user_theme_preference';
  AppThemeType _currentTheme = AppThemeType.princess;

  ThemeProvider() {
    _loadTheme();
  }

  AppThemeType get currentThemeType => _currentTheme;

  ThemeData get currentThemeData {
    switch (_currentTheme) {
      case AppThemeType.queen:
        return AppThemes.queenTheme;
      case AppThemeType.minimalist:
        return AppThemes.minimalistTheme;
      case AppThemeType.princess:
      default:
        return AppThemes.princessTheme;
    }
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeKey);
    if (themeIndex != null) {
      _currentTheme = AppThemeType.values[themeIndex];
      notifyListeners();
    }
  }

  Future<void> setTheme(AppThemeType type) async {
    _currentTheme = type;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, type.index);
  }
}


