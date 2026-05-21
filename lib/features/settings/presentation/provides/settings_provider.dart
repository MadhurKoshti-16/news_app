import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _kThemeModeKey = 'theme_mode';
const String _kFontSizeKey = 'font_size';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences not yet initialised');
});

class SettingsState {
  const SettingsState({
    this.themeMode = ThemeMode.system,
    this.fontSize = 14.0,
  });

  final ThemeMode themeMode;
  final double fontSize;

  SettingsState copyWith({ThemeMode? themeMode, double? fontSize}) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      fontSize: fontSize ?? this.fontSize,
    );
  }
}

final settingsNotifierProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>(
      (ref) => SettingsNotifier(ref.watch(sharedPreferencesProvider)),
    );

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier(this._prefs) : super(const SettingsState()) {
    _loadSettings();
  }

  final SharedPreferences _prefs;

  void _loadSettings() {
    final themeIndex = _prefs.getInt(_kThemeModeKey) ?? ThemeMode.system.index;
    final fontSize = _prefs.getDouble(_kFontSizeKey) ?? 14.0;

    state = SettingsState(
      themeMode: ThemeMode.values[themeIndex],
      fontSize: fontSize,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _prefs.setInt(_kThemeModeKey, mode.index);
  }

  Future<void> setFontSize(double size) async {
    state = state.copyWith(fontSize: size);
    await _prefs.setDouble(_kFontSizeKey, size);
  }

  Future<void> toggleTheme() async {
    final next = state.themeMode == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    await setThemeMode(next);
  }
}
