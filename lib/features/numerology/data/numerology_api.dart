import 'dart:convert';
import 'package:http/http.dart' as http;
import '../presentation/providers/numerology_providers.dart';

class NumerologyApi {
  const NumerologyApi({required this.baseUrl, required this.apiKey});
  final String baseUrl;
  final String apiKey;

  /// Map a section to your API endpoint path.
  /// Keep these as-is; provider decides which sections call API vs local calc.
  String _pathFor(NumerologySection s) {
    switch (s) {
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
      // nameList is handled by a custom widget (no API call)
        throw UnimplementedError();
    }
  }

  /// Example: GET <baseUrl>/<path>
  /// NOTE: We keep this function unchanged (no new parameters).
  Future<Map<String, dynamic>> fetchSection(NumerologySection section) async {
    final uri = Uri.parse('$baseUrl${_pathFor(section)}');

    final res = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': apiKey, // remove if not needed
      },
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('API ${res.statusCode}: ${res.body}');
    }

    final body = jsonDecode(res.body);
    if (body is Map<String, dynamic>) return body;

    if (body is List) {
      return {'items': body};
    }

    return {'result': body};
  }
}
