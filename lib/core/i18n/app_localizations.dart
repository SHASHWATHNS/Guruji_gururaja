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
    // Home tiles + common
    'home.horoscope': {'en': 'HOROSCOPE', 'ta': 'ஜாதகம்'},
    'home.match': {'en': 'THIRUMANA\nPORUTHAM', 'ta': 'திருமண\nபொருத்தம்'},
    'home.panchanga': {'en': 'PANCHANGAM', 'ta': 'பஞ்சாங்கம்'},
    'home.numerology': {'en': 'NUMEROLOGY', 'ta': 'எண் கணிதம்'},
    'home.jammukul': {'en': 'JAMMUKUL\nPRASHANA', 'ta': 'ஜாமக்கோள்\nபிரஷ்னா'},
    'home.tarot': {'en': 'TAROT', 'ta': 'டாரட்'},
    'home.purchase': {'en': 'PURCHASE', 'ta': 'கொள்முதல்'},
    'home.about': {'en': 'ABOUT', 'ta': 'தகவல்'},
    'home.feedback': {'en': 'CLASS\nFEEDBACK', 'ta': 'வகுப்பு\nகருத்து'},
    'home.transit': {'en': 'TRANSIT DATA', 'ta': 'கிரகப் பயணம்'},
    'home.video': {'en': 'CLASS\nVIDEO', 'ta': 'வகுப்பு\nவீடியோ'},
    'home.youtube': {'en': 'YOUTUBE\nVIDEO', 'ta': 'யூடியூப்\nவீடியோ'},
    'home.settings': {'en': 'SETTINGS', 'ta': 'அமைப்புகள்'},
    'common.coming': {'en': '— coming soon', 'ta': '— விரைவில்'},

// Panchanga buttons
    'panchanga.prev': {'en': 'PREVIOUS DAY', 'ta': 'முந்தைய நாள்'},
    'panchanga.next': {'en': 'NEXT DAY', 'ta': 'அடுத்த நாள்'},

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
