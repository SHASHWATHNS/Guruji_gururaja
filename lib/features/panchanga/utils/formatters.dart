class DateParts {
  final int year, month, day;
  DateParts(this.year, this.month, this.day);
}

DateParts dateToParts(DateTime d) => DateParts(d.year, d.month, d.day);

// "6:12:25" -> "06:12"
String hhmmFromHms(String source) {
  if (source.isEmpty) return '00:00';
  final p = source.split(':');
  final h = p.isNotEmpty ? p[0].padLeft(2, '0') : '00';
  final m = p.length > 1 ? p[1].padLeft(2, '0') : '00';
  return '$h:$m';
}
