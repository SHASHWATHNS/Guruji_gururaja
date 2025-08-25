import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  final ThemeMode themeMode;
  final Locale locale;

  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.locale = const Locale('en'),
  });

  AppSettings copyWith({ThemeMode? themeMode, Locale? locale}) =>
      AppSettings(themeMode: themeMode ?? this.themeMode, locale: locale ?? this.locale);
}

class AppSettingsNotifier extends StateNotifier<AppSettings> {
  AppSettingsNotifier() : super(const AppSettings()) {
    _load();
  }

  static const _kTheme = 'app_theme_mode';
  static const _kLocale = 'app_locale_code';

  Future<void> _load() async {
    final sp = await SharedPreferences.getInstance();
    final tm = sp.getString(_kTheme);
    final lc = sp.getString(_kLocale);

    ThemeMode theme = ThemeMode.system;
    if (tm == 'light') theme = ThemeMode.light;
    if (tm == 'dark') theme = ThemeMode.dark;

    Locale loc = const Locale('en');
    if (lc == 'ta') loc = const Locale('ta');

    state = state.copyWith(themeMode: theme, locale: loc);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kTheme, mode.name); // 'system' | 'light' | 'dark'
  }

  Future<void> setLocale(Locale locale) async {
    state = state.copyWith(locale: locale);
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kLocale, locale.languageCode); // 'en' | 'ta'
  }
}

final appSettingsProvider =
StateNotifierProvider<AppSettingsNotifier, AppSettings>((ref) => AppSettingsNotifier());
