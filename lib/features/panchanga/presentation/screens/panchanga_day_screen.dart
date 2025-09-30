import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/usecases/fetch_day_panchanga.dart';
import '../../data/repositories/panchanga_repository.dart';

/// —— Providers ————————————————————————————————————————————————
final _repoProvider = Provider<PanchangaRepository>((_) => PanchangaRepository());
final _usecaseProvider =
Provider<FetchDayPanchanga>((ref) => FetchDayPanchanga(ref.watch(_repoProvider)));

/// Selected date (today by default)
final selectedDateProvider = StateProvider<DateTime>((_) => DateTime.now());

/// Location/timezone used in the app
final locationSettingsProvider =
Provider<LocationSettings>((_) => const LocationSettings());

class LocationSettings {
  const LocationSettings({
    this.latitude = 11.0168, // Coimbatore sample
    this.longitude = 76.9558,
    this.timezone = 5.5,
  });
  final double latitude;
  final double longitude;
  final double timezone;
}

final dayPanchangaProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final date = ref.watch(selectedDateProvider);
  final ls = ref.watch(locationSettingsProvider);
  final uc = ref.watch(_usecaseProvider);
  return uc(
    date: date,
    lat: ls.latitude,
    lon: ls.longitude,
    tz: ls.timezone,
  );
});

/// —— Screen ————————————————————————————————————————————————
class PanchangaDayScreen extends ConsumerWidget {
  const PanchangaDayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = ref.watch(selectedDateProvider);
    final async = ref.watch(dayPanchangaProvider);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        // Title row with ‹ date › controls
        title: Row(
          children: [
            IconButton(
              tooltip: 'Previous day',
              icon: const Icon(Icons.chevron_left),
              onPressed: () {
                ref.read(selectedDateProvider.notifier).state =
                    date.subtract(const Duration(days: 1));
              },
            ),
            Expanded(
              child: Center(
                child: Text(
                  _fmtDate(date),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
              ),
            ),
            IconButton(
              tooltip: 'Next day',
              icon: const Icon(Icons.chevron_right),
              onPressed: () {
                ref.read(selectedDateProvider.notifier).state =
                    date.add(const Duration(days: 1));
              },
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Padding(
          padding: const EdgeInsets.all(24),
          child: Text('Failed: $e', style: const TextStyle(fontSize: 16)),
        ),
        data: (m) => _Body(m),
      ),
    );
  }

  String _fmtDate(DateTime d) {
    // e.g. 4-9-2025  |  Thu
    final day = '${d.day}-${d.month}-${d.year}';
    final wd = DateFormat('EEE').format(d);
    return '$day  |  $wd';
  }
}

class _Body extends StatelessWidget {
  const _Body(this.m);
  final Map<String, dynamic> m;

  String _timeRange(Map? mm) {
    if (mm == null) return '-';
    final s = (mm['starts_at'] ?? mm['start'] ?? '').toString();
    final e = (mm['ends_at'] ?? mm['end'] ?? '').toString();
    if (s.isEmpty || e.isEmpty) return '-';
    String hhmm(String x) {
      // Accept "2025-09-04 06:12:28" or "6:12:22"
      final t = x.split(' ').last;
      final parts = t.split(':');
      if (parts.length < 2) return t;
      return '${parts[0]}:${parts[1]}';
    }
    return '${hhmm(s)} – ${hhmm(e)}';
  }

  String _firstName(Map? mapOfItems) {
    if (mapOfItems == null || mapOfItems.isEmpty) return '-';
    final first = (mapOfItems.values.first);
    if (first is Map && first['name'] != null) return first['name'].toString();
    return '-';
  }

  @override
  Widget build(BuildContext context) {
    final sunrise = (m['sunrise_sunset'] ?? const {}) as Map;
    final tithi = (m['tithi'] ?? const {}) as Map;
    final nak = (m['nakshatra'] ?? const {}) as Map;
    final yoga = (m['yoga'] ?? const {}) as Map;
    final karana = (m['karana'] ?? const {}) as Map;
    final gb = (m['goodbad'] ?? const {}) as Map;
    final weekday = (m['weekday'] ?? const {}) as Map;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _ChipRow(
          'சூரிய உதயம்/அஸ்தமனம்',
          '${(sunrise['sun_rise_time'] ?? '').toString()} – ${(sunrise['sun_set_time'] ?? '').toString()}',
        ),
        _ChipRow('திதி', (tithi['name'] ?? '-').toString()),
        _ChipRow('நக்ஷத்திரம்', (nak['name'] ?? '-').toString()),
        _ChipRow('யோகம்', _firstName(yoga)),
        _ChipRow('கரணம்', _firstName(karana)),

        const SizedBox(height: 14),
        const Divider(height: 1),

        _ChipRow('ராகு காலம்', _timeRange(gb['rahu_kaalam_data'] as Map?)),
        _ChipRow('எமகண்டம்', _timeRange(gb['yama_gandam_data'] as Map?)),
        _ChipRow('குளிகை', _timeRange(gb['gulika_kalam_data'] as Map?)),
        _ChipRow('அபிஜித்', _timeRange(gb['abhijit_data'] as Map?)),
        _ChipRow('பிரம்ம முகூர்த்தம்', _timeRange(gb['brahma_muhurat_data'] as Map?)),
        _ChipRow('அமிர்த காலம்', _timeRange(gb['amrit_kaal_data'] as Map?)),

        const SizedBox(height: 14),
        _ChipRow('வார நாள்', (weekday['weekday_name'] ?? '-').toString()),
      ],
    );
  }
}

class _ChipRow extends StatelessWidget {
  const _ChipRow(this.left, this.right);
  final String left;
  final String right;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              left,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            right.isEmpty ? '-' : right,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
