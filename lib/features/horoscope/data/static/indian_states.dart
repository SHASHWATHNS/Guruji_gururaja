// lib/features/horoscope/data/geo/indian_places.dart
class IndianPlace {
  final String state;
  final String district;
  final double lat;
  final double lng;
  final String tzid;

  const IndianPlace({
    required this.state,
    required this.district,
    required this.lat,
    required this.lng,
    this.tzid = 'Asia/Kolkata',
  });
}

const indianPlaces = <IndianPlace>[
  IndianPlace(state: 'Karnataka', district: 'Bengaluru', lat: 12.9716, lng: 77.5946),
  IndianPlace(state: 'Karnataka', district: 'Bellary', lat: 15.1394, lng: 76.9214),
  IndianPlace(state: 'Tamil Nadu', district: 'Chennai', lat: 13.0827, lng: 80.2707),
  IndianPlace(state: 'Tamil Nadu', district: 'Coimbatore', lat: 11.0168, lng: 76.9558),
  IndianPlace(state: 'Maharashtra', district: 'Mumbai', lat: 19.0760, lng: 72.8777),
  IndianPlace(state: 'Maharashtra', district: 'Pune', lat: 18.5204, lng: 73.8567),
  IndianPlace(state: 'Delhi', district: 'New Delhi', lat: 28.6139, lng: 77.2090),
  // … keep adding (we can expand to all states/districts later)
];
