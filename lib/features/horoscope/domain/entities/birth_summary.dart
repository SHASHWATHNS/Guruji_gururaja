class BirthSummary {
  final String name;        // பெயர்
  final String dob;         // பிறந்த தேதி (dd-MM-yyyy)
  final String tob;         // பிறந்த நேரம் (HH:mm or "தெரியாது")
  final String city;        // பிறந்த ஊர்
  final String weekdayTa;   // நாள் (திங்கள்…)
  final String hinduDayTa;  // இந்து நாள் (same as weekday in Tamil for now)
  final String age;         // வயது x வருடம் y மாதம் z நாள்

  final String lagnam;      // லக்னம் (Tamil sign)
  final String raasi;       // ராசி (Moon sign in Tamil)
  final String star;        // நட்சத்திரம் (Tamil)
  final String thithi;      // திதி
  final String thithiSoonyam; // திதி சூனியம் (ஆம்/இல்லை/—)
  final String yogam;       // யோகம்
  final String yogiAvaYogi; // யோகி, அவயோகி
  final String karanam;     // கரணம்
  final String tamilMaadham;// தமிழ் மாதம்
  final String tamilVarudam;// தமிழ் வருடம்

  const BirthSummary({
    required this.name,
    required this.dob,
    required this.tob,
    required this.city,
    required this.weekdayTa,
    required this.hinduDayTa,
    required this.age,
    required this.lagnam,
    required this.raasi,
    required this.star,
    required this.thithi,
    required this.thithiSoonyam,
    required this.yogam,
    required this.yogiAvaYogi,
    required this.karanam,
    required this.tamilMaadham,
    required this.tamilVarudam,
  });
}
