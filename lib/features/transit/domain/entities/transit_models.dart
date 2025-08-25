import 'package:flutter/foundation.dart';

@immutable
class PlanetTransit {
  final String planet;          // e.g., "Sun"
  final String sign;            // e.g., "Leo"
  final double degree;          // e.g., 12.34
  final String nakshatra;       // e.g., "Magha"
  final int pada;               // 1..4
  final bool retrograde;        // true/false
  final double speed;           // degrees/day (or whatever source returns)
  final DateTime computedAt;    // timestamp of calculation

  const PlanetTransit({
    required this.planet,
    required this.sign,
    required this.degree,
    required this.nakshatra,
    required this.pada,
    required this.retrograde,
    required this.speed,
    required this.computedAt,
  });
}

@immutable
class TransitDay {
  final DateTime date;                 // local date (start of day)
  final String timezone;               // e.g., "Asia/Kolkata"
  final double latitude;               // for topocentric calcs if needed
  final double longitude;
  final List<PlanetTransit> planets;   // 9 navagrahas + optionally nodes

  const TransitDay({
    required this.date,
    required this.timezone,
    required this.latitude,
    required this.longitude,
    required this.planets,
  });
}
