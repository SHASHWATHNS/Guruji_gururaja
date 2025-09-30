class SunriseSunset {
  final String sunrise; // "6:12:25"
  final String sunset;  // "18:30:17"

  SunriseSunset({required this.sunrise, required this.sunset});

  factory SunriseSunset.fromApi(Map<String, dynamic> json) {
    final out = json['output'] as Map<String, dynamic>? ?? {};
    return SunriseSunset(
      sunrise: '${out['sun_rise_time'] ?? ''}',
      sunset:  '${out['sun_set_time'] ?? ''}',
    );
  }

  // "6:12:25" -> "06:12"
  static String _hhmm(String raw) {
    if (raw.isEmpty) return '00:00';
    final parts = raw.split(':');
    final h = parts.isNotEmpty ? parts[0].padLeft(2, '0') : '00';
    final m = parts.length > 1 ? parts[1].padLeft(2, '0') : '00';
    return '$h:$m';
  }

  String get sunriseHHmm => _hhmm(sunrise);
  String get sunsetHHmm  => _hhmm(sunset);
}
