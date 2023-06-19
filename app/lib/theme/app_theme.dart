import 'package:flutter/material.dart';
import 'color_schemes.g.dart';

class AppTheme {
  static AppTheme? _instance;
  bool _isDarkThemeApplied = true;
  AppTheme._();
  static AppTheme get instance => _instance ??= AppTheme._();
  final ValueNotifier<ColorScheme> _currrentColorScheme =
      ValueNotifier<ColorScheme>(darkColorScheme);
  ValueNotifier<ColorScheme> get currentColorScheme => _currrentColorScheme;
  bool get isDarkThemeApplied => _isDarkThemeApplied;

  void toggleTheme() {
    if (_currrentColorScheme.value == lightColorScheme) {
      _currrentColorScheme.value = darkColorScheme;
      _isDarkThemeApplied = true;
    } else {
      _currrentColorScheme.value = lightColorScheme;
      _isDarkThemeApplied = false;
    }
  }
}
