class NakshatraInfo {
  final int? number;
  final String? name;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final double? remainingPercentage;

  NakshatraInfo({this.number, this.name, this.startsAt, this.endsAt, this.remainingPercentage});

  factory NakshatraInfo.fromApi(Map<String, dynamic> json) {
    final out = json['output'] as Map<String, dynamic>? ?? {};
    return NakshatraInfo(
      number: out['number'] is int ? out['number'] : int.tryParse('${out['number'] ?? ''}'),
      name: out['name']?.toString(),
      startsAt: DateTime.tryParse('${out['starts_at'] ?? ''}'),
      endsAt: DateTime.tryParse('${out['ends_at'] ?? ''}'),
      remainingPercentage: (out['remaining_percentage_at_given_time'] is num)
          ? (out['remaining_percentage_at_given_time'] as num).toDouble()
          : null,
    );
  }
}
