
import '../datasources/panchanga_api_service.dart';

class TimeRange {
  final DateTime? start;
  final DateTime? end;

  const TimeRange({this.start, this.end});

  factory TimeRange.fromInline(String? inline) {
    final m = PanchangaApiService.parseInlineMap(inline);
    return TimeRange(
      start: DateTime.tryParse(m['starts_at'] ?? ''),
      end: DateTime.tryParse(m['ends_at'] ?? ''),
    );
  }

  String formatHHmm() {
    String fmt(DateTime? dt) {
      if (dt == null) return '00:00';
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return '$h:$m';
    }
    return '${fmt(start)} – ${fmt(end)}';
  }
}

class GoodBadTimes {
  final TimeRange? abhijit;
  final TimeRange? amritKaal;
  final TimeRange? brahmaMuhurat;
  final TimeRange? rahuKaalam;
  final TimeRange? yamaGandam;
  final TimeRange? gulikaKalam;
  final List<TimeRange> durMuhurat;
  final TimeRange? varjyam;

  const GoodBadTimes({
    this.abhijit,
    this.amritKaal,
    this.brahmaMuhurat,
    this.rahuKaalam,
    this.yamaGandam,
    this.gulikaKalam,
    this.durMuhurat = const [],
    this.varjyam,
  });

  factory GoodBadTimes.fromApi(Map<String, dynamic> json) {
    final abhijit = TimeRange.fromInline(json['abhijit_data'] as String?);
    final amrit = TimeRange.fromInline(json['amrit_kaal_data'] as String?);
    final brahma = TimeRange.fromInline(json['brahma_muhurat_data'] as String?);
    final rahu = TimeRange.fromInline(json['rahu_kaalam_data'] as String?);
    final yama = TimeRange.fromInline(json['yama_gandam_data'] as String?);
    final gulika = TimeRange.fromInline(json['gulika_kalam_data'] as String?);
    final varjyam = TimeRange.fromInline(json['varjyam_data'] as String?);

    final durList = <TimeRange>[];
    final durs = PanchangaApiService.parseIndexedInlineMap(json['dur_muhurat_data'] as String?);
    for (final m in durs) {
      durList.add(TimeRange(
        start: DateTime.tryParse(m['starts_at'] ?? ''),
        end: DateTime.tryParse(m['ends_at'] ?? ''),
      ));
    }

    return GoodBadTimes(
      abhijit: abhijit,
      amritKaal: amrit,
      brahmaMuhurat: brahma,
      rahuKaalam: rahu,
      yamaGandam: yama,
      gulikaKalam: gulika,
      durMuhurat: durList,
      varjyam: varjyam,
    );
  }
}
