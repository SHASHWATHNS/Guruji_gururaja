import 'dart:async';
import 'package:flutter/widgets.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static const supportedLocales = [Locale('en'), Locale('ta')];

  // Minimal keys used by Settings + a few common ones
  static const _s = <String, Map<String, String>>{
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
    'home.numerology': {'en': 'NUMEROLOGY', 'ta': 'நியூமராலஜி'},
    'home.jammukul': {'en': 'JAMAKKOL', 'ta': 'ஜாமக்கோள்'},
    'home.tarot': {'en': 'TAROT', 'ta': 'டாரட்'},
    'home.purchase': {'en': 'PURCHASE', 'ta': 'கொள்முதல்'},
    'home.about': {'en': 'ABOUT US', 'ta': 'எங்களைப் பற்றி தகவல்'},
    'home.feedback': {'en': 'CLASS\nFEEDBACK', 'ta': 'வகுப்பு\nகருத்துக்கள்'},
    'home.transit': {'en': 'PLANET\nMOVEMENT', 'ta': 'கோச்சாரம்'},
    'home.video': {'en': 'CLASS\nVIDEOS', 'ta': 'வகுப்பு\nவீடியோ'},
    'home.youtube': {'en': 'YOUTUBE\nVIDEO', 'ta': 'யூடியூப்\nவீடியோ'},
    'home.settings': {'en': 'SETTINGS', 'ta': 'அமைப்புகள்'},
    'common.coming': {'en': '— coming soon', 'ta': '— விரைவில்'},

// Panchanga buttons
    'panchanga.prev': {'en': 'PREVIOUS DAY', 'ta': 'முந்தைய நாள்'},
    'panchanga.next': {'en': 'NEXT DAY', 'ta': 'அடுத்த நாள்'},
// matching
    // Matching (Star/Rasi) screen
    'match.chip': {'en': 'MATCHING', 'ta': 'பொருத்தம்'},
    'match.section.bride': {'en': 'Bride Details', 'ta': 'பெண் விவரம்'},
    'match.section.groom': {'en': 'Groom Details', 'ta': 'ஆண் விவரம்'},
    'match.name': {'en': 'Full Name', 'ta': 'முழுப் பெயர்'},
    'match.nakshatra': {'en': 'Nakshatra', 'ta': 'நட்சத்திரம்'},
    'match.rasi': {'en': 'Rasi (Zodiac)', 'ta': 'ராசி'},
    'match.calculate': {'en': 'CALCULATE', 'ta': 'பொருத்தம்'},
    'match.error.requiredAll': {
      'en': 'Please enter name and select nakshatra & rasi for both.',
      'ta': 'பெயர், நட்சத்திரம், ராசி — இருவருக்கும் தேர்ந்தெடுக்கவும்.'},
    'match.result.title': {'en': 'Porutham Scores', 'ta': 'பொருத்த மதிப்பெண்கள்'},
    'match.result.total': {'en': 'Total', 'ta': 'மொத்தம்'},

// Class Feedback
    'fb.chip': {'en': 'CLASS FEEDBACK', 'ta': 'வகுப்பு கருத்து'},
    'fb.section.student': {'en': 'Student Details', 'ta': 'மாணவர் விவரங்கள்'},
    'fb.section.experience': {'en': 'Class Experience', 'ta': 'வகுப்பு அனுபவம்'},

    'fb.name': {'en': 'Full Name', 'ta': 'முழுப் பெயர்'},
    'fb.phone': {'en': 'Phone Number', 'ta': 'தொலைபேசி எண்'},
    'fb.phone.invalid': {'en': 'Enter a valid phone number', 'ta': 'சரியான எண்ணை உள்ளிடவும்'},

    'fb.course': {'en': 'Course', 'ta': 'பாடநெறி'},
    'fb.course.basic': {'en': 'Basic Astrology', 'ta': 'அடிப்படை ஜோதிடம்'},
    'fb.course.prashna': {'en': 'Prashna', 'ta': 'பிரஷ்னா'},
    'fb.course.matching': {'en': 'Matching', 'ta': 'பொருத்தம்'},
    'fb.course.panchanga': {'en': 'Panchanga', 'ta': 'பஞ்சாங்கம்'},
    'fb.course.numerology': {'en': 'Numerology', 'ta': 'எண் கணிதம்'},
    'fb.course.other': {'en': 'Other', 'ta': 'மற்றவை'},

    'fb.rating': {'en': 'Your Rating', 'ta': 'உங்கள் மதிப்பீடு'},
    'fb.good': {'en': 'What went well?', 'ta': 'நன்றாக இருந்தவை'},
    'fb.improve': {'en': 'What can improve?', 'ta': 'மேம்படுத்த வேண்டியவை'},
    'fb.recommend': {'en': 'I would recommend this class', 'ta': 'இந்த வகுப்பை பரிந்துரைப்பேன்'},

    'fb.submit': {'en': 'SUBMIT FEEDBACK', 'ta': 'கருத்தை சமர்ப்பிக்கவும்'},

    'fb.required': {'en': 'Required', 'ta': 'தேவை'},
    'fb.error.rating': {'en': 'Please select a rating.', 'ta': 'மதிப்பீட்டைத் தேர்ந்தெடுக்கவும்.'},
    'fb.error.course': {'en': 'Please choose a course.', 'ta': 'பாடநெறியைத் தேர்ந்தெடுக்கவும்.'},

    'fb.success': {'en': 'Thank you! Your feedback was submitted.', 'ta': 'நன்றி! உங்கள் கருத்து பதிவானது.'},
    'fb.fail': {'en': 'Submission failed. Please try again.', 'ta': 'சமர்ப்பிப்பு தோல்வி. மறுபடியும் முயற்சிக்கவும்.'},
// About page
    'about.chip': {'en': 'ABOUT', 'ta': 'தகவல்'},
    'about.name': {'en': 'Guruji Gururaja', 'ta': 'குருஜி குருராஜா'},
    'about.role': {'en': 'Astrologer & Researcher', 'ta': 'ஜோதிட ஆசான் & ஆராய்ச்சியாளர்'},

    'about.section.bio': {'en': 'Biography', 'ta': 'சுருக்கம்'},
    'about.bio.origin': {
      'en': 'Born and raised in Narasothipatti (Salem district). Originally named Yuvaraja, later changed to Guruji Gururaja for auspicious progress.',
      'ta': 'சேலம் மாவட்டம், நரசோத்திப்பட்டி பகுதியில் பிறந்து வளர்ந்தார். முதற்பெயர் “யுவராஜா”; முன்னேற்ற நன்மைக்காக “குருஜி குருராஜா” என மாற்றினார்.'
    },
    'about.bio.inspiration': {
      'en': 'Meeting astrologer Balaji transformed his path; accurate predictions deepened his faith in astrology.',
      'ta': 'ஜோதிடர் பாலாஜியை சந்தித்தது வாழ்க்கைப் பாதையை மாற்றியது; அவர் கூறிய கணிப்புகள் ஒன்றன்பின் ஒன்றாக நனவாகி ஜோதிட நம்பிக்கையை வலுப்படுத்தின.'
    },
    'about.bio.work': {
      'en': 'Studied with several Gurus; analysed around 20,000 horoscopes; created structured astrology courses and began teaching — including free classes.',
      'ta': 'பல குருமார்களிடம் பயின்று, சுமார் 20,000 ஜாதகங்களை ஆய்வு செய்தார்; முறையான ஜோதிடப் பாடத்திட்டங்களை உருவாக்கி, இலவச வகுப்புகள் உட்பட கற்பித்தல் தொடங்கினார்.'
    },
    'about.bio.trust': {
      'en': 'Founded the “Guruji Gururaja Spiritual Trust” on Karthigai Deepam day, 2021. Over 1,500 students have benefited; conferences conducted, books published, and certificates awarded.',
      'ta': '2021-ஆம் ஆண்டு கார்த்திகை தீபத் திருநாளன்று “குருஜி குருராஜா ஸ்பிரிச்சுவாலிட்டி டிரஸ்ட்” அமைப்பை தொடங்கினார். இதுவரை 1,500-க்கும் மேற்பட்டவர்கள் பயனடைந்துள்ளனர்; ஜோதிட மாநாடுகள், நூல் வெளியீடுகள், சான்றிதழ்கள் வழங்கல் போன்றவை நடைபெற்றுள்ளன.'
    },

    'about.section.contact': {'en': 'Reach Guruji', 'ta': 'குருஜியை தொடர்புகொள்ள'},
    'about.contact.location': {'en': 'Narasothipatti, Salem, Tamil Nadu', 'ta': 'நரசோத்திப்பட்டி, சேலம், தமிழ்நாடு'},
    'about.contact.phone': {'en': 'Phone', 'ta': 'தொலைபேசி'},
    'about.email': {'en': 'Email', 'ta': 'மின்னஞ்சல்'},
    'about.website': {'en': 'Website', 'ta': 'இணையதளம்'},
    'about.youtube': {'en': 'YouTube Channel', 'ta': 'யூடியூப் சேனல்'},
    'about.share': {'en': 'Share App', 'ta': 'ஆப்பை பகிர்'},


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
