// lib/features/horoscope/tabs/dasa/dasha_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../form/horoscope_form_screen.dart' show birthDataProvider, BirthData;
import 'dasha_providers.dart';
import 'dasha_service.dart';

/// -------- Local helpers --------
DateTime? _p(String? s) {
  if (s == null || s.isEmpty) return null;
  try {
    return DateTime.parse(s.length == 10 ? s : s.replaceFirst(' ', 'T'));
  } catch (_) {
    return null;
  }
}

final _fmt = DateFormat('dd-MM-yyyy HH:mm'); // final format
String _f(DateTime? dt) => dt == null ? '—' : _fmt.format(dt);

/// ===== Entry: Tab builds Screen 1 (Mahā) =====
class DashaTab extends ConsumerWidget {
  const DashaTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bd = ref.watch(birthDataProvider);
    if (bd == null) {
      return const Center(child: Text('Please fill the form first.'));
    }
    return _MahaScreen(bd: bd);
  }
}

/// =================== Screen 1: Mahā (Daśā) ===================
class _MahaScreen extends ConsumerWidget {
  final BirthData bd;
  const _MahaScreen({required this.bd});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mahaAsync = ref.watch(mahaProvider(bd));
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(title: const Text('Mahā Daśā')),
      body: mahaAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Error: $e', style: const TextStyle(color: Colors.red)),
        ),
        data: (mahas) {
          if (mahas.isEmpty) return const Center(child: Text('No data.'));
          final svc = ref.read(dashaServiceProvider);
          final activeIdx = svc.activeIndex(mahas, now);
          Map<String, dynamic> selected = activeIdx >= 0 ? mahas[activeIdx] : mahas.first;

          return Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                DropdownButtonFormField<Map<String, dynamic>>(
                  value: selected,
                  isExpanded: true,
                  items: mahas.map((m) => DropdownMenuItem(
                    value: m,
                    child: Text('${m['lord']} (${m['start']} → ${m['end']})',
                        overflow: TextOverflow.ellipsis),
                  )).toList(),
                  onChanged: (v) => selected = v ?? selected,
                  decoration: const InputDecoration(labelText: 'Select Mahā', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    itemCount: mahas.length,
                    itemBuilder: (_, i) {
                      final m = mahas[i];
                      final s = _p(m['start'] as String?);
                      final e = _p(m['end'] as String?);
                      final active = i == activeIdx;
                      return Card(
                        color: active ? Colors.yellow.shade200 : null, // yellow highlight
                        child: ListTile(
                          title: Text(m['lord'] ?? '-'),
                          subtitle: Text('${_f(s)} → ${_f(e)}', overflow: TextOverflow.ellipsis),
                          onTap: () => _goBhukti(context, bd, m),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => _goBhukti(context, bd, selected),
                    child: const Text('Next: Bhukti'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _goBhukti(BuildContext context, BirthData bd, Map<String, dynamic> maha) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => _BhuktiScreen(bd: bd, maha: maha)));
  }
}

/// =================== Screen 2: Bhukti (Antar) ===================
class _BhuktiScreen extends ConsumerWidget {
  final BirthData bd;
  final Map<String, dynamic> maha;
  const _BhuktiScreen({required this.bd, required this.maha});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lord = (maha['lord'] ?? '').toString();
    final antarAsync = ref.watch(antarProvider(AntarKey(bd, lord)));
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(title: Text('Bhukti — ${maha['lord']}')),
      body: antarAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Error: $e', style: const TextStyle(color: Colors.red)),
        ),
        data: (antars) {
          if (antars.isEmpty) return const Center(child: Text('No data.'));
          final svc = ref.read(dashaServiceProvider);
          final activeIdx = svc.activeIndex(antars, now);
          Map<String, dynamic> selected = activeIdx >= 0 ? antars[activeIdx] : antars.first;

          return Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                DropdownButtonFormField<Map<String, dynamic>>(
                  value: selected,
                  isExpanded: true,
                  items: antars.map((a) => DropdownMenuItem(
                    value: a,
                    child: Text('${a['lord']} (${a['start']} → ${a['end']})',
                        overflow: TextOverflow.ellipsis),
                  )).toList(),
                  onChanged: (v) => selected = v ?? selected,
                  decoration: const InputDecoration(labelText: 'Select Bhukti', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    itemCount: antars.length,
                    itemBuilder: (_, i) {
                      final a = antars[i];
                      final s = _p(a['start'] as String?);
                      final e = _p(a['end'] as String?);
                      final active = i == activeIdx;
                      return Card(
                        color: active ? Colors.yellow.shade200 : null,
                        child: ListTile(
                          title: Text(a['lord'] ?? '-'),
                          subtitle: Text('${_f(s)} → ${_f(e)}', overflow: TextOverflow.ellipsis),
                          onTap: () => _goPraty(context, a),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => _goPraty(context, selected),
                    child: const Text('Next: Antar (Pratyantar)'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _goPraty(BuildContext context, Map<String, dynamic> antar) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => _PratyScreen(antar: antar)));
  }
}

/// =================== Screen 3: Antar (Pratyantar, computed) ===================
class _PratyScreen extends ConsumerWidget {
  final Map<String, dynamic> antar;
  const _PratyScreen({required this.antar});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pratyAsync = ref.watch(pratyantarProvider(PratyKey(antar)));
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(title: Text('Antar — ${antar['lord']}')),
      body: pratyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Error: $e', style: const TextStyle(color: Colors.red)),
        ),
        data: (pratys) {
          if (pratys.isEmpty) return const Center(child: Text('No data.'));
          final svc = ref.read(dashaServiceProvider);
          final activeIdx = svc.activeIndex(pratys, now);
          Map<String, dynamic> selected = activeIdx >= 0 ? pratys[activeIdx] : pratys.first;

          return Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                DropdownButtonFormField<Map<String, dynamic>>(
                  value: selected,
                  isExpanded: true,
                  items: pratys.map((p) => DropdownMenuItem(
                    value: p,
                    child: Text('${p['lord']} (${p['start']} → ${p['end']})',
                        overflow: TextOverflow.ellipsis),
                  )).toList(),
                  onChanged: (v) => selected = v ?? selected,
                  decoration: const InputDecoration(labelText: 'Select Antar (Pratyantar)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    itemCount: pratys.length,
                    itemBuilder: (_, i) {
                      final p = pratys[i];
                      final s = _p(p['start'] as String?);
                      final e = _p(p['end'] as String?);
                      final active = i == activeIdx;
                      return Card(
                        color: active ? Colors.yellow.shade200 : null,
                        child: ListTile(
                          title: Text(p['lord'] ?? '-'),
                          subtitle: Text('${_f(s)} → ${_f(e)}', overflow: TextOverflow.ellipsis),
                          onTap: () => _goSook(context, p),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => _goSook(context, selected),
                    child: const Text('Next: Sūkṣma'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _goSook(BuildContext context, Map<String, dynamic> praty) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => _SookScreen(praty: praty)));
  }
}

/// =================== Screen 4: Sūkṣma (computed) ===================
class _SookScreen extends ConsumerWidget {
  final Map<String, dynamic> praty;
  const _SookScreen({required this.praty});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sookAsync = ref.watch(sookshmaProvider(SookKey(praty)));
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(title: Text('Sūkṣma — ${praty['lord']}')),
      body: sookAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Error: $e', style: const TextStyle(color: Colors.red)),
        ),
        data: (sooks) {
          if (sooks.isEmpty) return const Center(child: Text('No data.'));
          final svc = ref.read(dashaServiceProvider);
          final activeIdx = svc.activeIndex(sooks, now);
          Map<String, dynamic> selected = activeIdx >= 0 ? sooks[activeIdx] : sooks.first;

          return Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                DropdownButtonFormField<Map<String, dynamic>>(
                  value: selected,
                  isExpanded: true,
                  items: sooks.map((s) => DropdownMenuItem(
                    value: s,
                    child: Text('${s['lord']} (${s['start']} → ${s['end']})',
                        overflow: TextOverflow.ellipsis),
                  )).toList(),
                  onChanged: (v) => selected = v ?? selected,
                  decoration: const InputDecoration(labelText: 'Select Sūkṣma', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    itemCount: sooks.length,
                    itemBuilder: (_, i) {
                      final s = sooks[i];
                      final ss = _p(s['start'] as String?);
                      final ee = _p(s['end'] as String?);
                      final active = i == activeIdx;
                      return Card(
                        color: active ? Colors.yellow.shade200 : null,
                        child: ListTile(
                          title: Text(s['lord'] ?? '-'),
                          subtitle: Text('${_f(ss)} → ${_f(ee)}', overflow: TextOverflow.ellipsis),
                          onTap: () => _goPrana(context, s),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => _goPrana(context, selected),
                    child: const Text('Next: Prāṇa'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _goPrana(BuildContext context, Map<String, dynamic> sook) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => _PranaScreen(sook: sook)));
  }
}

/// =================== Screen 5: Prāṇa (computed) ===================
class _PranaScreen extends ConsumerWidget {
  final Map<String, dynamic> sook;
  const _PranaScreen({required this.sook});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pranaAsync = ref.watch(pranaProvider(PranaKey(sook)));
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(title: Text('Prāṇa — ${sook['lord']}')),
      body: pranaAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Error: $e', style: const TextStyle(color: Colors.red)),
        ),
        data: (pranas) {
          if (pranas.isEmpty) return const Center(child: Text('No data.'));
          final svc = ref.read(dashaServiceProvider);
          final activeIdx = svc.activeIndex(pranas, now);

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: pranas.length,
            itemBuilder: (_, i) {
              final p = pranas[i];
              final s = _p(p['start'] as String?);
              final e = _p(p['end'] as String?);
              final active = i == activeIdx;
              return Card(
                color: active ? Colors.yellow.shade200 : null,
                child: ListTile(
                  title: Text(p['lord'] ?? '-'),
                  subtitle: Text('${_f(s)} → ${_f(e)}', overflow: TextOverflow.ellipsis),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
