import 'dart:convert';
import 'package:http/http.dart' as http;
import '../presentation/providers/numerology_providers.dart';

class NumerologyApi {
  const NumerologyApi({required this.baseUrl, required this.apiKey});
  final String baseUrl;
  final String apiKey;

  /// Map a section to your API endpoint path.
  /// TODO: Replace these with your real paths (or query params).
  String _pathFor(NumerologySection s) {
    switch (s) {
      case NumerologySection.jadagarinVivaram:
        return '/numerology/jadagarin-vivaram';
      case NumerologySection.kattangalLuckyNumbers:
        return '/numerology/kattangal-lucky-numbers';
      case NumerologySection.cellNumber:
        return '/numerology/cell-number';
      case NumerologySection.name:
        return '/numerology/name';
      case NumerologySection.vehicleNumber:
        return '/numerology/vehicle-number';
      case NumerologySection.luckyColor:
        return '/numerology/lucky-color';
      case NumerologySection.stones:
        return '/numerology/stones';
      case NumerologySection.nameList:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  /// Example: GET <baseUrl>/<path>
  /// Add query parameters here if your API needs them (e.g., name, dob).
  Future<Map<String, dynamic>> fetchSection(NumerologySection section) async {
    final uri = Uri.parse('$baseUrl${_pathFor(section)}');

    final res = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': apiKey, // remove if your API doesn’t need it
      },
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('API ${res.statusCode}: ${res.body}');
    }

    final body = jsonDecode(res.body);
    if (body is Map<String, dynamic>) return body;

    // If API returns a list, wrap it
    if (body is List) {
      return {'items': body};
    }

    return {'result': body};
  }
}
