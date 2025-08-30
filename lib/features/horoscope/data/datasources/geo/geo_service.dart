import 'dart:convert';
import 'package:dio/dio.dart';

class GeoService {
  GeoService({required this.googleApiKey, Dio? dio})
      : _dio = dio ?? Dio(BaseOptions(connectTimeout: const Duration(seconds: 12)));

  final String googleApiKey;
  final Dio _dio;

  Future<List<PlaceSuggestion>> autocomplete({
    required String input,
    String language = 'en',
    String? sessionToken,
    String? country, // e.g., 'IN'
  }) async {
    if (input.trim().isEmpty) return const [];
    final qp = <String, dynamic>{
      'input': input,
      'types': 'geocode',
      'language': language,
      'key': googleApiKey,
      if (sessionToken != null) 'sessiontoken': sessionToken,
      if (country != null) 'components': 'country:$country',
    };
    final res = await _dio.get(
      'https://maps.googleapis.com/maps/api/place/autocomplete/json',
      queryParameters: qp,
    );
    final data = res.data is String ? json.decode(res.data) : res.data;
    final preds = (data['predictions'] as List? ?? []);
    return preds
        .map((p) => PlaceSuggestion(label: p['description'], placeId: p['place_id']))
        .toList();
  }

  Future<PlaceDetails> details({required String placeId}) async {
    final res = await _dio.get(
      'https://maps.googleapis.com/maps/api/place/details/json',
      queryParameters: {
        'place_id': placeId,
        'fields': 'geometry/location,formatted_address',
        'key': googleApiKey,
      },
    );
    final data = res.data is String ? json.decode(res.data) : res.data;
    final result = data['result'];
    final loc = result['geometry']['location'];
    return PlaceDetails(
      label: result['formatted_address'],
      lat: (loc['lat'] as num).toDouble(),
      lng: (loc['lng'] as num).toDouble(),
    );
  }

  Future<TimeZoneInfo> timezone({
    required double lat,
    required double lng,
    required DateTime localDateTime,
  }) async {
    final ts = (localDateTime.toUtc().millisecondsSinceEpoch / 1000).round();
    final res = await _dio.get(
      'https://maps.googleapis.com/maps/api/timezone/json',
      queryParameters: {
        'location': '$lat,$lng',
        'timestamp': ts,
        'key': googleApiKey,
      },
    );
    final data = res.data is String ? json.decode(res.data) : res.data;
    return TimeZoneInfo(
      tzid: data['timeZoneId'] ?? 'UTC',
      rawOffset: (data['rawOffset'] as num?)?.toInt() ?? 0,
      dstOffset: (data['dstOffset'] as num?)?.toInt() ?? 0,
    );
  }
}

class PlaceSuggestion {
  final String label;
  final String placeId;
  const PlaceSuggestion({required this.label, required this.placeId});
}

class PlaceDetails {
  final String label;
  final double lat;
  final double lng;
  const PlaceDetails({required this.label, required this.lat, required this.lng});
}

class TimeZoneInfo {
  final String tzid;
  final int rawOffset; // seconds
  final int dstOffset; // seconds
  const TimeZoneInfo({required this.tzid, required this.rawOffset, required this.dstOffset});
}
