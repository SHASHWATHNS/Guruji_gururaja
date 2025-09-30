import 'dart:async';
import 'package:flutter/widgets.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static const supportedLocales = [Locale('en'), Locale('ta')];

  // ───────────────────────── Strings ─────────────────────────
  static const _s = <String, Map<String, String>>{
    // Settings / Common
    'chip.settings': {'en': 'SETTINGS', 'ta': 'அமைப்புகள்'},
    'settings.preferences': {'en': 'Preferences', 'ta': 'விருப்பங்கள்'},
    'settings.theme': {'en': 'Theme', 'ta': 'தோற்றம்'},
    'settings.theme.system': {'en': 'System', 'ta': 'கணினி'},
    'settings.theme.light': {'en': 'Light', 'ta': 'ஒளி'},
    'settings.theme.dark': {'en': 'Dark', 'ta': 'இருள்'},
    'settings.language': {'en': 'Language', 'ta': 'மொழி'},
    'settings.logout': {'en': 'LOG OUT', 'ta': 'வெளியேறு'},

    // Home tiles
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

    // Common actions
    'common.submit': {'en': 'Submit', 'ta': 'சமர்ப்பிக்கவும்'},
    'common.required': {'en': 'Required', 'ta': 'தேவை'},
    'common.invalidNumber': {'en': 'Invalid number', 'ta': 'தவறான எண்'},
    'common.history': {'en': 'History', 'ta': 'வரலாறு'},
    'common.search': {'en': 'Search', 'ta': 'தேடல்'},
    'common.error': {'en': 'Error', 'ta': 'பிழை'},
    'common.editable': {'en': 'Editable', 'ta': 'திருத்தக்கூடியது'},
    'common.unnamed': {'en': '(Unnamed)', 'ta': '(பெயரற்றது)'},
    'common.cancel': {'en': 'Cancel', 'ta': 'ரத்து செய்'},
    'common.clear': {'en': 'Clear', 'ta': 'அழிக்கவும்'},
    'common.delete': {'en': 'Delete', 'ta': 'நீக்கு'},

    // Form
    'form.title': {'en': 'Horoscope — Form', 'ta': 'ஜாதகம் — படிவம்'},
    'form.name': {'en': 'Name', 'ta': 'பெயர்'},
    'form.hint.date': {'en': 'yyyy-mm-dd', 'ta': 'yyyy-mm-dd'},
    'form.hint.time': {'en': 'hh:mm', 'ta': 'hh:mm'},
    'form.location': {'en': 'Location', 'ta': 'பிறந்த இடம்'},
    'form.country': {'en': 'Country', 'ta': 'நாடு'},
    'form.state': {'en': 'State', 'ta': 'மாநிலம்'},
    'form.district': {'en': 'District', 'ta': 'மாவட்டம்'},
    'form.latitude': {'en': 'Latitude', 'ta': 'அட்சரேகை'},
    'form.longitude': {'en': 'Longitude', 'ta': 'தேக்கரேகை'},
    'form.tapSelect': {'en': 'Tap to select', 'ta': 'தெரிவு செய்யத் தட்டவும்'},
    'form.fillFirst': {'en': 'Fill the form first.', 'ta': 'முதலில் படிவத்தை பூர்த்தி செய்யவும்.'},
    'form.fillFirst.polite': {'en': 'Please fill the form first.', 'ta': 'முதலில் படிவத்தை பூர்த்தி செய்யவும்.'},
    'form.loading.locations': {'en': 'Loading locations…', 'ta': 'இடங்கள் ஏற்றப்படுகிறது…'},
    'form.select.country': {'en': 'Select Country', 'ta': 'நாட்டைத் தேர்வு செய்க'},
    'form.select.state': {'en': 'Select State', 'ta': 'மாநிலத்தைத் தேர்வு செய்க'},
    'form.select.district': {'en': 'Select District', 'ta': 'மாவட்டத்தைத் தேர்வு செய்க'},
    'form.unknown.state': {'en': 'Unknown State', 'ta': 'அறியாத மாநிலம்'},
    'form.unknown.district': {'en': 'Unknown District', 'ta': 'அறியாத மாவட்டம்'},

    // History
    'snackbar.entryDeleted': {'en': 'Entry deleted', 'ta': 'உள்ளீடு நீக்கப்பட்டது'},
    'history.title': {'en': 'History', 'ta': 'வரலாறு'},
    'history.title.recent': {'en': 'Recent Horoscopes', 'ta': 'சமீபத்திய ஜாதகங்கள்'},
    'history.none': {'en': 'No history yet.', 'ta': 'இதுவரை வரலாறு இல்லை.'},
    'history.clearAll': {'en': 'Clear all', 'ta': 'அனைத்தையும் அழிக்கவும்'},
    'history.clear.confirm.title': {'en': 'Clear history?', 'ta': 'வரலாற்றை அழிக்கவா?'},
    'history.clear.confirm.body': {
      'en': 'This will remove all saved entries.',
      'ta': 'சேமித்த எல்லா பதிவுகளும் நீக்கப்படும்.'
    },
    'history.delete.confirm.title': {'en': 'Delete entry?', 'ta': 'பதிவை நீக்கவா?'},
    'history.delete.confirm.body.fallback': {'en': 'This entry', 'ta': 'இந்த பதிவு'},

    // Tabs / Titles
    'horoscope.title': {'en': 'Horoscope', 'ta': 'ஜாதகம்'},
    'tabs.summary': {'en': 'Summary', 'ta': 'ஜாதகரின்\nவிவரம்'},
    'tabs.chart': {'en': 'Chart', 'ta': 'கட்டங்கள்'},
    'tabs.dasha': {'en': 'Dasha', 'ta': 'தசா'},
    'tabs.navamsa': {'en': 'Navāṁśa', 'ta': 'நவாம்சம்'},

    // Summary tab labels
    'label.name': {'en': 'Name', 'ta': 'பெயர்'},
    'label.birthplace': {'en': 'Birthplace', 'ta': 'பிறந்த இடம்'},
    'label.dob': {'en': 'DOB', 'ta': 'பிறந்த தேதி'},
    'label.tob': {'en': 'TOB', 'ta': 'பிறந்த நேரம்'},
    'label.english.weekday': {'en': 'English Weekday', 'ta': 'ஆங்கில வாரநாள்'},
    'label.tamil.day': {'en': 'Tamil Day', 'ta': 'தமிழ் நாள்'},
    'label.age': {'en': 'Age', 'ta': 'வயது'},
    'label.lagnam': {'en': 'Lagnam', 'ta': 'லக்னம்'},
    'label.raasi': {'en': 'Rāsi', 'ta': 'ராசி'},
    'label.nakshatra': {'en': 'Nakshatra', 'ta': 'நட்சத்திரம்'},
    'label.tithi': {'en': 'Tithi', 'ta': 'திதி'},
    'label.tithi_soonyam': {'en': 'Tithi Soonyam', 'ta': 'திதி சூனியம்'},
    'label.paksha': {'en': 'Paksha', 'ta': 'பிறை'}, // Only in the first file's list
    'label.yoga': {'en': 'Yoga', 'ta': 'யோகம்'},
    'label.karana': {'en': 'Karana', 'ta': 'கரணம்'},
    'label.yogi_nakshatra': {'en': 'Yogi', 'ta': 'யோகி'},
    'label.avayogi_nakshatra': {'en': 'Avayogi', 'ta': 'அவயோகி'},
    'label.tamil.month': {'en': 'Tamil Month', 'ta': 'தமிழ் மாதம்'},
    'label.tamil.year': {'en': 'Tamil Year', 'ta': 'தமிழ் ஆண்டு'},
    'label.sun.deg': {'en': 'Sun (°)', 'ta': 'சூரியன் (°)'},
    'label.moon.deg': {'en': 'Moon (°)', 'ta': 'சந்திரன் (°)'},

    // Summary errors
    'summary.error': {'en': 'Summary error', 'ta': 'சுருக்கத்தில் பிழை'},

    // Standalone translations for paksha values
    'paksha.valarpirai': {'en': 'Valarpirai', 'ta': 'வளர்பிறை'},
    'paksha.theypirai': {'en': 'Theypirai', 'ta': 'தேய்பிறை'},

    // Chart sections / errors
    'chart.raasi.title': {'en': 'Rāśi (Kattangal)', 'ta': 'ராசிக்கட்டம்'},
    'chart.navamsa.title': {'en': 'Navāṁśa (Navamsa Kattam)', 'ta': 'நவாம்சக்கட்டம்'},
    'chart.planets.extended': {'en': 'Planets — Extended', 'ta': 'கிரகங்கள் — விரிவான'},
    'chart.error': {'en': 'Charts error', 'ta': 'வரைபட பிழை'},
    'chart.raasi.error': {'en': 'Rāśi error', 'ta': 'ராசி பிழை'},
    'chart.navamsa.error': {'en': 'Navāṁśa error', 'ta': 'நவாம்சம் பிழை'},
    'planets.error': {'en': 'Planets error', 'ta': 'கிரகங்கள் பிழை'},
    'api.noSvg': {'en': 'No SVG from API', 'ta': 'API-யிலிருந்து SVG இல்லை'}, // Only in the second file
    'data.noPlanetData': {'en': 'No planet data.', 'ta': 'கிரகத் தரவு இல்லை.'}, // Only in the second file
    'data.noPlanetRows': {'en': 'No planet rows.', 'ta': 'கிரக வரிசைகள் இல்லை.'}, // Only in the second file

    // Planets table headers
    'planets.col.body': {'en': 'Body', 'ta': 'கிரகம்'},
    'planets.col.sign': {'en': 'Sign', 'ta': 'ராசி'},
    'planets.col.lord': {'en': 'Lord', 'ta': 'அதிபதி'},
    'planets.col.house': {'en': 'H', 'ta': 'பா'},
    'planets.col.deg': {'en': '°', 'ta': '°'},
    'planets.col.min': {'en': '\'', 'ta': '\''},
    'planets.col.sec': {'en': '"', 'ta': '"'},
    'planets.col.nakshatra': {'en': 'Nakshatra', 'ta': 'நட்சத்திரம்'}, // Only in the second file
    'planets.col.pada': {'en': 'Pada', 'ta': 'பாதம்'}, // Only in the second file


    // Panchanga buttons (elsewhere)
    'panchanga.prev': {'en': 'PREVIOUS DAY', 'ta': 'முந்தைய நாள்'},
    'panchanga.next': {'en': 'NEXT DAY', 'ta': 'அடுத்த நாள்'},

    // Matching (kept as-is from your file)
    'match.chip': {'en': 'MATCHING', 'ta': 'பொருத்தம்'},
    'match.section.bride': {'en': 'Bride Details', 'ta': 'பெண் விவரம்'},
    'match.section.groom': {'en': 'Groom Details', 'ta': 'ஆண் விவரம்'},
    'match.name': {'en': 'Full Name', 'ta': 'முழுப் பெயர்'},
    'match.nakshatra': {'en': 'Nakshatra', 'ta': 'நட்சத்திரம்'},
    'match.rasi': {'en': 'Rasi (Zodiac)', 'ta': 'ராசி'},
    'match.calculate': {'en': 'CALCULATE', 'ta': 'பொருத்தம்'},
    'match.error.requiredAll': {
      'en': 'Please enter name and select nakshatra & rasi for both.',
      'ta': 'பெயர், நட்சத்திரம், ராசி — இருவருக்கும் தேர்ந்தெடுக்கவும்.'
    },
    'match.result.title': {'en': 'Porutham Scores', 'ta': 'பொருத்த மதிப்பெண்கள்'},
    'match.result.total': {'en': 'Total', 'ta': 'மொத்தம்'},

    // Feedback (kept)
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

    // About
    'about.chip': {'en': 'ABOUT', 'ta': 'தகவல்'},
    'about.name': {'en': 'Guruji Gururaja', 'ta': 'குருஜி குருராஜா'},
    'about.role': {'en': 'Astrologer & Researcher', 'ta': 'ஜோதிட ஆசான் & ஆராய்ச்சியாளர்'},
    'about.section.bio': {'en': 'Biography', 'ta': 'சுருக்கம்'},
    'about.bio.origin': {
      'en':
      'Born and raised in Narasothipatti (Salem district). Originally named Yuvaraja, later changed to Guruji Gururaja for auspicious progress.',
      'ta':
      'சேலம் மாவட்டம், நரசோத்திப்பட்டி பகுதியில் பிறந்து வளர்ந்தார். முதற்பெயர் “யுவராஜா”; முன்னேற்ற நன்மைக்காக “குருஜி குருராஜா” என மாற்றினார்.'
    },
    'about.bio.inspiration': {
      'en':
      'Meeting astrologer Balaji transformed his path; accurate predictions deepened his faith in astrology.',
      'ta':
      'ஜோதிடர் பாலாஜியை சந்தித்தது வாழ்க்கைப் பாதையை மாற்றியது; அவர் கூறிய கணிப்புகள் ஒன்றன்பின் ஒன்றாக நனவாகி ஜோதிட நம்பிக்கையை வலுப்படுத்தின.'
    },
    'about.bio.work': {
      'en':
      'Studied with several Gurus; analysed around 20,000 horoscopes; created structured astrology courses and began teaching — including free classes.',
      'ta':
      'பல குருமார்களிடம் பயின்று, சுமார் 20,000 ஜாதகங்களை ஆய்வு செய்தார்; முறையான ஜோதிடப் பாடத்திட்டங்களை உருவாக்கி, இலவச வகுப்புகள் உட்பட கற்பித்தல் தொடங்கினார்.'
    },
    'about.bio.trust': {
      'en':
      'Founded the “Guruji Gururaja Spiritual Trust” on Karthigai Deepam day, 2021. Over 1,500 students have benefited; conferences conducted, books published, and certificates awarded.',
      'ta':
      '2021-ஆம் ஆண்டு கார்த்திகை தீபத் திருநாளன்று “குருஜி குருராஜா ஸ்பிரிச்சுவாலிட்டி டிரஸ்ட்” அமைப்பை தொடங்கினார். இதுவரை 1,500-க்கும் மேற்பட்டவர்கள் பயனடைந்துள்ளனர்; ஜோதிட மாநாடுகள், நூல் வெளியீடுகள், சான்றிதழ்கள் வழங்கல் போன்றவை நடைபெற்றுள்ளன.'
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