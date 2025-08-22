enum Gender { male, female }

class HoroscopeForm {
  final String name;
  final int? day;
  final int? month;
  final int? year;

  /// Time of birth
  /// hour: 0–24 (24 = next day 00:00)
  /// minute/second: 0–59
  final int? hour;
  final int? minute;
  final int? second;

  /// Place of birth (free text or chosen from list)
  final String place;

  /// Longitude (deg/min + E/W)
  final int? lonDeg;     // 0..180
  final int? lonMin;     // 0..59
  final String lonDir;   // 'E' or 'W'

  /// Latitude (deg/min + N/S)
  final int? latDeg;     // 0..90
  final int? latMin;     // 0..59
  final String latDir;   // 'N' or 'S'

  /// Timezone (+/- hours:minutes)
  /// Example: India = +05:30 → tzHour=5, tzMinute=30
  final int tzHour;      // can be negative
  final int tzMinute;    // always positive minute component (0..59)

  final Gender gender;

  final bool saveInPhone;

  const HoroscopeForm({
    this.name = '',
    this.day,
    this.month,
    this.year,
    this.hour,
    this.minute,
    this.second,
    this.place = '',
    this.lonDeg,
    this.lonMin,
    this.lonDir = 'E',
    this.latDeg,
    this.latMin,
    this.latDir = 'N',
    this.tzHour = 5,
    this.tzMinute = 30,
    this.gender = Gender.male,
    this.saveInPhone = true,
  });

  HoroscopeForm copyWith({
    String? name,
    int? day,
    int? month,
    int? year,
    int? hour,
    int? minute,
    int? second,
    String? place,
    int? lonDeg,
    int? lonMin,
    String? lonDir,
    int? latDeg,
    int? latMin,
    String? latDir,
    int? tzHour,
    int? tzMinute,
    Gender? gender,
    bool? saveInPhone,
  }) {
    return HoroscopeForm(
      name: name ?? this.name,
      day: day ?? this.day,
      month: month ?? this.month,
      year: year ?? this.year,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      second: second ?? this.second,
      place: place ?? this.place,
      lonDeg: lonDeg ?? this.lonDeg,
      lonMin: lonMin ?? this.lonMin,
      lonDir: lonDir ?? this.lonDir,
      latDeg: latDeg ?? this.latDeg,
      latMin: latMin ?? this.latMin,
      latDir: latDir ?? this.latDir,
      tzHour: tzHour ?? this.tzHour,
      tzMinute: tzMinute ?? this.tzMinute,
      gender: gender ?? this.gender,
      saveInPhone: saveInPhone ?? this.saveInPhone,
    );
  }

  // -------------------- Validation helpers --------------------

  /// Validates that the date fields form a real calendar date, not in the future.
  bool get hasValidDate {
    if (day == null || month == null || year == null) return false;
    final d = day!, m = month!, y = year!;
    if (y < 1500 || y > 2200) return false;
    if (m < 1 || m > 12) return false;
    if (d < 1 || d > 31) return false;
    try {
      final dt = DateTime(y, m, d);
      if (dt.day != d || dt.month != m || dt.year != y) return false; // catches 31/02 etc.
      if (dt.isAfter(DateTime.now())) return false;
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Validates time with rule: hour 0..24; if hour==24 then minute==0 && second==0.
  bool get hasValidTime {
    if (hour == null || minute == null || second == null) return false;
    final h = hour!, min = minute!, sec = second!;
    if (h < 0 || h > 24) return false;
    if (min < 0 || min > 59) return false;
    if (sec < 0 || sec > 59) return false;
    if (h == 24 && (min != 0 || sec != 0)) return false;
    return true;
  }

  /// Validates basic lat/lon components & directions.
  bool get hasValidLatLon {
    if (latDeg == null || latMin == null || lonDeg == null || lonMin == null) return false;
    final ld = latDeg!, lm = latMin!, od = lonDeg!, om = lonMin!;
    if (!(latDir == 'N' || latDir == 'S')) return false;
    if (!(lonDir == 'E' || lonDir == 'W')) return false;
    if (ld < 0 || ld > 90) return false;
    if (lm < 0 || lm > 59) return false;
    if (od < 0 || od > 180) return false;
    if (om < 0 || om > 59) return false;
    return true;
  }

  /// Returns decimal latitude (positive=N, negative=S) if components valid; otherwise null.
  double? get decimalLatitude {
    if (!hasValidLatLon) return null;
    final deg = latDeg!.toDouble();
    final min = latMin!.toDouble();
    final val = deg + (min / 60.0);
    return latDir == 'S' ? -val : val;
    // Range ensured in hasValidLatLon
  }

  /// Returns decimal longitude (positive=E, negative=W) if components valid; otherwise null.
  double? get decimalLongitude {
    if (!hasValidLatLon) return null;
    final deg = lonDeg!.toDouble();
    final min = lonMin!.toDouble();
    final val = deg + (min / 60.0);
    return lonDir == 'W' ? -val : val;
    // Range ensured in hasValidLatLon
  }

  /// Total timezone offset in minutes. Example: +05:30 → 330, -04:00 → -240
  int get tzTotalMinutes {
    // tzHour may be negative; tzMinute is the absolute minute component
    final sign = tzHour < 0 ? -1 : 1;
    final absMin = tzMinute.abs().clamp(0, 59);
    return tzHour * 60 + sign * absMin;
  }

  /// Combined basic validation for submit.
  bool get isValidBasic =>
      name.trim().isNotEmpty &&
          place.trim().isNotEmpty &&
          hasValidDate &&
          hasValidTime &&
          hasValidLatLon;
}
