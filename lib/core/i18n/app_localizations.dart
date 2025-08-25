import 'dart:async';
import 'package:flutter/widgets.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static const supportedLocales = [Locale('en'), Locale('ta')];

  // Minimal keys used by Settings + a few common ones
  static const _s = <String, Map<String, String>>{
    'app.title': {'en': 'GURUJI GURURAJA', 'ta': 'குருஜி குருராஜா'},
    'chip.settings': {'en': 'SETTINGS', 'ta': 'அமைப்புகள்'},

    'settings.preferences': {'en': 'Preferences', 'ta': 'விருப்பங்கள்'},
    'settings.theme': {'en': 'Theme', 'ta': 'தோற்றம்'},
    'settings.theme.system': {'en': 'System', 'ta': 'கணினி'},
    'settings.theme.light': {'en': 'Light', 'ta': 'ஒளி'},
    'settings.theme.dark': {'en': 'Dark', 'ta': 'இருள்'},
    'settings.language': {'en': 'Language', 'ta': 'மொழி'},
    'settings.logout': {'en': 'LOG OUT', 'ta': 'வெளியேறு'},
  };

  String t(String key) {
    final m = _s[key];
    if (m == null) return key;
    return m[locale.languageCode] ?? m['en'] ?? key;
  }

  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations)!;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();
  @override
  bool isSupported(Locale locale) =>
      AppLocalizations.supportedLocales.any((l) => l.languageCode == locale.languageCode);
  @override
  Future<AppLocalizations> load(Locale locale) async => AppLocalizations(locale);
  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) => false;
}

const appLocalizationsDelegate = _AppLocalizationsDelegate();

extension L10nExt on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
