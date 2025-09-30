import 'dart:convert';

class KaranaItem {
  final int? number;
  final String? name;
  final DateTime? completion;
  final double? leftPercentage;

  KaranaItem({this.number, this.name, this.completion, this.leftPercentage});
}

class KaranaInfo {
  final List<KaranaItem> items;

  KaranaInfo(this.items);

  factory KaranaInfo.fromApi(Map<String, dynamic> json) {
    final raw = json['output'];
    Map<String, dynamic> m;
    if (raw is String) {
      m = Map<String, dynamic>.from(jsonDecode(raw));
    } else {
      m = Map<String, dynamic>.from(raw as Map? ?? {});
    }
    final list = <KaranaItem>[];
    for (final k in m.keys) {
      final v = m[k] as Map<String, dynamic>? ?? {};
      list.add(KaranaItem(
        number: v['number'] is int ? v['number'] : int.tryParse('${v['number'] ?? ''}'),
        name: v['name']?.toString(),
        completion: DateTime.tryParse('${v['completion'] ?? ''}'),
        leftPercentage: (v['karana_left_percentage'] is num) ? (v['karana_left_percentage'] as num).toDouble() : null,
      ));
    }
    return KaranaInfo(list);
  }

  KaranaItem? get first => items.isNotEmpty ? items.first : null;
}
