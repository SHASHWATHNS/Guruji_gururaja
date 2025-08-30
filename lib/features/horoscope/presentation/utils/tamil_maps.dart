// Tamil labels & maps used in Jadagarin Vivaram

const tamilWeekdays = [
  'திங்கள்', 'செவ்வாய்', 'புதன்', 'வியாழன்', 'வெள்ளி', 'சனி', 'ஞாயிறு',
];
// Dart's DateTime.weekday: 1=Mon..7=Sun → index map:
String weekdayTa(DateTime d) => tamilWeekdays[(d.weekday - 1) % 7];

// Western/vedic sign → Tamil (Mesham..Meenam)
const signTa = {
  'Aries': 'மேஷம்',
  'Taurus': 'ரிஷபம்',
  'Gemini': 'மிதுனம்',
  'Cancer': 'கடகம்',
  'Leo': 'சிம்மம்',
  'Virgo': 'கன்னி',
  'Libra': 'துலாம்',
  'Scorpio': 'விருச்சிகம்',
  'Sagittarius': 'தனுசு',
  'Capricorn': 'மகரம்',
  'Aquarius': 'கும்பம்',
  'Pisces': 'மீனம்',
};

// 27 nakshatra → Tamil
const nakshatraTa = {
  'Ashwini': 'அசுவினி',
  'Bharani': 'பரணி',
  'Krittika': 'கார்த்திகை',
  'Rohini': 'ரோகிணி',
  'Mrigashira': 'மிருகசீரிடம்',
  'Ardra': 'திருவாதிரை',
  'Punarvasu': 'புனர்பூசம்',
  'Pushya': 'புஷ்யம்',
  'Ashlesha': 'ஆயில்யம்',
  'Magha': 'மகம்',
  'Purva Phalguni': 'பூரம்',
  'Uttara Phalguni': 'உத்திரம்',
  'Hasta': 'ஹஸ்தம்',
  'Chitra': 'சித்திரை',
  'Swati': 'சுவாதி',
  'Vishakha': 'விசாகம்',
  'Anuradha': 'அனுஷம்',
  'Jyeshtha': 'கேட்டை',
  'Mula': 'மூலம்',
  'Purva Ashadha': 'பூராடம்',
  'Uttara Ashadha': 'உத்திராடம்',
  'Shravana': 'திருவோணம்',
  'Dhanishta': 'அவிட்டம்',
  'Shatabhisha': 'சதயம்',
  'Purva Bhadrapada': 'பூரட்டாதி',
  'Uttara Bhadrapada': 'உத்திரட்டாதி',
  'Revati': 'ரேவதி',
};

String asTamilSign(String eng) => signTa[eng] ?? eng;
String asTamilNak(String eng) => nakshatraTa[eng] ?? eng;
