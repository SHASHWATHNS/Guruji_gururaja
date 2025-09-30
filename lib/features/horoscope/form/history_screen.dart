import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ⬇️ adjust this relative import if needed (e.g., '../../../core/i18n/app_localizations.dart')
import '../../../core/i18n/app_localizations.dart';

import 'horoscope_form_screen.dart' show BirthData;
import '../data/local_store.dart';

class HoroscopeHistoryScreen extends StatefulWidget {
  const HoroscopeHistoryScreen({super.key});

  @override
  State<HoroscopeHistoryScreen> createState() => _HoroscopeHistoryScreenState();
}

class _HoroscopeHistoryScreenState extends State<HoroscopeHistoryScreen> {
  late Future<List<BirthData>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<BirthData>> _load() async {
    final raw = await LocalStore.loadHistoryRaw();
    final items = raw.map((j) => BirthData.fromJson(j)).toList();
    return items.take(10).toList(); // latest 10 only
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat.yMMMd();

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.t('history.title.recent'))),
      body: FutureBuilder<List<BirthData>>(
        future: _future,
        builder: (ctx, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('${context.l10n.t('common.error')}: ${snap.error}'));
          }
          final items = snap.data ?? const <BirthData>[];
          if (items.isEmpty) {
            return Center(child: Text(context.l10n.t('entries.noneRecent')));
          }

          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final b = items[i];
              final subtitle = [
                b.district.isNotEmpty ? b.district : null,
                b.state.isNotEmpty ? b.state : null,
                b.country.isNotEmpty ? b.country : null,
              ].whereType<String>().join(', ');

              final time =
                  '${dateFmt.format(b.dob)} • ${TimeOfDay(hour: b.tob.hour, minute: b.tob.minute).format(context)}';

              return ListTile(
                title: Text(b.name.isEmpty ? context.l10n.t('common.unnamed') : b.name),
                subtitle: Text('$subtitle\n$time'),
                isThreeLine: true,
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.pop(context, b), // return to Form
              );
            },
          );
        },
      ),
    );
  }
}
