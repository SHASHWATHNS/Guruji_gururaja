class BirthInput {
  final String name;
  final DateTime dobLocal; // date only
  final String? tob24h;    // "HH:mm" if known, else null
  final bool unknownTime;

  final String placeLabel;
  final double lat;
  final double lng;
  final String tzid;       // IANA, e.g., Asia/Kolkata

  const BirthInput({
    required this.name,
    required this.dobLocal,
    required this.tob24h,
    required this.unknownTime,
    required this.placeLabel,
    required this.lat,
    required this.lng,
    required this.tzid,
  });
}
