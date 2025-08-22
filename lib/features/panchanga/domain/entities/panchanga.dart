import 'package:flutter/foundation.dart';

@immutable
class PanchangaItem {
  final String label;      // e.g., "Vedic Day"
  final String value;      // e.g., "Thursday"
  final String? timeText;  // optional small time or note line
  const PanchangaItem({required this.label, required this.value, this.timeText});
}

@immutable
class PanchangaSection {
  final bool thickDividerBefore; // draw a thick line before this block
  final List<PanchangaItem> items;
  const PanchangaSection({this.thickDividerBefore = false, required this.items});
}

@immutable
class PanchangaData {
  final DateTime date;
  final List<PanchangaSection> sections;
  const PanchangaData({required this.date, required this.sections});
}
