import 'dart:convert';

class YogaItem {
  final int? number;
  final String? name;
  final DateTime? completion;
  final double? leftPercentage;

  YogaItem({this.number, this.name, this.completion, this.leftPercentage});
}

class YogaInfo {
  final List<YogaItem> items;

  YogaInfo(this.items);

  factory YogaInfo.fromApi(Map<String, dynamic> json) {
    final raw = json['output'];
    Map<String, dynamic> m;
    if (raw is String) {
      m = Map<String, dynamic>.from(jsonDecode(raw));
    } else {
      m = Map<String, dynamic>.from(raw as Map? ?? {});
    }
    final list = <YogaItem>[];
    for (final k in m.keys) {
      final v = m[k] as Map<String, dynamic>? ?? {};
      list.add(YogaItem(
        number: v['number'] is int ? v['number'] : int.tryParse('${v['number'] ?? ''}'),
        name: v['name']?.toString(),
        completion: DateTime.tryParse('${v['completion'] ?? ''}'),
        leftPercentage: (v['yoga_left_percentage'] is num) ? (v['yoga_left_percentage'] as num).toDouble() : null,
      ));
    }
    return YogaInfo(list);
  }

  YogaItem? get first => items.isNotEmpty ? items.first : null;
}
