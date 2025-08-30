// lib/features/horoscope/data/static/indian_place.dart
// Simple static dataset + helpers (South India sample; extend anytime)

class IndianPlace {
  final String state;
  final String district;
  final double lat;
  final double lng;
  final String tzid; // IST for all of India

  const IndianPlace({
    required this.state,
    required this.district,
    required this.lat,
    required this.lng,
    this.tzid = 'Asia/Kolkata',
  });
}

/// Famous South Indian districts (starter set)
const List<IndianPlace> indianPlaces = [
  // Tamil Nadu
  IndianPlace(state: 'Tamil Nadu', district: 'Chennai',        lat: 13.0827, lng: 80.2707),
  IndianPlace(state: 'Tamil Nadu', district: 'Coimbatore',     lat: 11.0168, lng: 76.9558),
  IndianPlace(state: 'Tamil Nadu', district: 'Madurai',        lat: 9.9252,  lng: 78.1198),
  IndianPlace(state: 'Tamil Nadu', district: 'Tiruchirappalli',lat: 10.7905, lng: 78.7047),


  // Karnataka
  IndianPlace(state: 'Karnataka',   district: 'Bengaluru Urban', lat: 12.9716, lng: 77.5946),
  IndianPlace(state: 'Karnataka',   district: 'Mysuru',          lat: 12.2958, lng: 76.6394),
  IndianPlace(state: 'Karnataka',   district: 'Ballari',         lat: 15.1394, lng: 76.9214),

  // Kerala
  IndianPlace(state: 'Kerala',      district: 'Thiruvananthapuram', lat: 8.5241, lng: 76.9366),
  IndianPlace(state: 'Kerala',      district: 'Kochi',              lat: 9.9312, lng: 76.2673),
  IndianPlace(state: 'Kerala',      district: 'Kozhikode',          lat: 11.2588, lng: 75.7804),

  // Andhra Pradesh
  IndianPlace(state: 'Andhra Pradesh', district: 'Visakhapatnam', lat: 17.6868, lng: 83.2185),
  IndianPlace(state: 'Andhra Pradesh', district: 'Vijayawada',    lat: 16.5062, lng: 80.6480),

  // Telangana
  IndianPlace(state: 'Telangana',   district: 'Hyderabad',       lat: 17.3850, lng: 78.4867),
  IndianPlace(state: 'Telangana',   district: 'Warangal',        lat: 17.9689, lng: 79.5941),
];

/// --- Helper functions (pure) ---

/// Unique list of states, sorted A→Z
List<String> allStates() {
  final s = indianPlaces.map((e) => e.state).toSet().toList();
  s.sort();
  return s;
}

/// District names for a state, sorted A→Z
List<String> districtsFor(String state) {
  final d = indianPlaces.where((e) => e.state == state).map((e) => e.district).toSet().toList();
  d.sort();
  return d;
}

/// Find the IndianPlace by state + district
IndianPlace? findPlace(String state, String district) {
  for (final p in indianPlaces) {
    if (p.state == state && p.district == district) return p;
  }
  return null;
}
