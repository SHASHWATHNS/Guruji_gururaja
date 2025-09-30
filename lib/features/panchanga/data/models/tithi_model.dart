import 'dart:convert';

class TithiInfo {
  final int? number;
  final String? name;
  final String? paksha;
  final DateTime? completesAt;
  final double? leftPercentage;

  TithiInfo({this.number, this.name, this.paksha, this.completesAt, this.leftPercentage});

  factory TithiInfo.fromApi(Map<String, dynamic> json) {
    // API sometimes returns "output" as a JSON string
    final raw = json['output'];
    Map data;
    if (raw is String) {
      data = jsonDecode(raw);
    } else if (raw is Map) {
      data = raw;
    } else {
      data = {};
    }
    return TithiInfo(
      number: data['number'] is int ? data['number'] : int.tryParse('${data['number'] ?? ''}'),
      name: data['name']?.toString(),
      paksha: data['paksha']?.toString(),
      completesAt: DateTime.tryParse('${data['completes_at'] ?? ''}'),
      leftPercentage: (data['left_precentage'] is num) ? (data['left_precentage'] as num).toDouble() : null,
    );
  }
}
