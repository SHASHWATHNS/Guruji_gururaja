// lib/features/horoscope/form/horoscope_form_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle, FilteringTextInputFormatter;
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ⬇️ adjust this relative import if needed
import '../../../core/i18n/app_localizations.dart';

import '../data/local_store.dart';
import '../presentation/screens/horoscope_tabs_screen.dart';

// -------------------- Model + Provider --------------------

class BirthData {
  final String name;
  final DateTime dob;
  final TimeOfDay tob;
  final String country, state, district;
  final double? lat, lon;
  final String timezone;

  const BirthData({
    required this.name,
    required this.dob,
    required this.tob,
    required this.country,
    required this.state,
    required this.district,
    this.lat,
    this.lon,
    this.timezone = 'Asia/Kolkata',
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'dob': dob.toIso8601String(),
    'tobHour': tob.hour,
    'tobMinute': tob.minute,
    'country': country,
    'state': state,
    'district': district,
    'lat': lat,
    'lon': lon,
    'timezone': timezone,
  };

  factory BirthData.fromJson(Map<String, dynamic> j) => BirthData(
    name: j['name'] ?? '',
    dob: DateTime.parse(j['dob'] as String),
    tob: TimeOfDay(hour: j['tobHour'] as int, minute: j['tobMinute'] as int),
    country: j['country'] ?? '',
    state: j['state'] ?? '',
    district: j['district'] ?? '',
    lat: (j['lat'] as num?)?.toDouble(),
    lon: (j['lon'] as num?)?.toDouble(),
    timezone: j['timezone'] ?? 'Asia/Kolkata',
  );
}

final birthDataProvider = StateProvider<BirthData?>((_) => null);

// -------------------- Screen --------------------

class HoroscopeFormScreen extends ConsumerStatefulWidget {
  const HoroscopeFormScreen({super.key, this.onSubmitted});
  final VoidCallback? onSubmitted; // optional; we’ll navigate by default

  @override
  ConsumerState<HoroscopeFormScreen> createState() => _HoroscopeFormScreenState();
}

class _HoroscopeFormScreenState extends ConsumerState<HoroscopeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  DateTime? _dob;
  TimeOfDay? _tob;

  final _country = TextEditingController();
  final _state = TextEditingController();
  final _district = TextEditingController();
  final _lat = TextEditingController();
  final _lon = TextEditingController();

  bool _loadingLoc = true;
  String? _loadErr;
  late Map<String, Map<String, List<_District>>> _byCountryState;

  bool _prefilledOnce = false; // prefill when we return from Tabs

  @override
  void initState() {
    super.initState();
    _loadLoc();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // If provider has data (e.g., returning from Tabs), prefill once.
    final bd = ref.read(birthDataProvider);
    if (!_prefilledOnce && bd != null) {
      _prefilledOnce = true;
      _prefillFrom(bd);
    }
  }

  void _prefillFrom(BirthData bd) {
    _name.text = bd.name;
    _dob = bd.dob;
    _tob = bd.tob;
    _country.text = bd.country;
    _state.text = bd.state;
    _district.text = bd.district;
    _lat.text = (bd.lat ?? '').toString();
    _lon.text = (bd.lon ?? '').toString();
  }

  @override
  void dispose() {
    _name.dispose();
    _country.dispose();
    _state.dispose();
    _district.dispose();
    _lat.dispose();
    _lon.dispose();
    super.dispose();
  }

  Future<void> _loadLoc() async {
    try {
      final txt = await rootBundle.loadString('assets/state_lat_lon.json');
      _byCountryState = _normalizeToCountryStateDistrict(json.decode(txt));
      setState(() => _loadingLoc = false);
    } catch (e) {
      setState(() {
        _loadErr = '${context.l10n.t('error.locationLoadFailed')}: $e';
        _loadingLoc = false;
      });
    }
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final res = await showDatePicker(
      context: context,
      firstDate: DateTime(1900),
      lastDate: now,
      initialDate: _dob ?? DateTime(now.year - 20, now.month, now.day),
    );
    if (res != null) setState(() => _dob = res);
  }

  Future<void> _pickTob() async {
    final res = await showTimePicker(
      context: context,
      initialTime: _tob ?? const TimeOfDay(hour: 6, minute: 0),
    );
    if (res != null) setState(() => _tob = res);
  }

  Future<void> _pickCountry() async {
    if (_loadingLoc || _loadErr != null) return;
    final items = _byCountryState.keys.toList()..sort();
    final v = await _picker<String>(context.l10n.t('form.select.country'), items, (s) => s);
    if (v != null && v != _country.text) {
      setState(() {
        _country.text = v;
        _state.clear();
        _district.clear();
        _lat.clear();
        _lon.clear();
      });
    }
  }

  Future<void> _pickState() async {
    final c = _country.text.trim();
    if (c.isEmpty) return;
    final items = _byCountryState[c]!.keys.toList()..sort();
    final v = await _picker<String>(context.l10n.t('form.select.state'), items, (s) => s);
    if (v != null && v != _state.text) {
      setState(() {
        _state.text = v;
        _district.clear();
        _lat.clear();
        _lon.clear();
      });
    }
  }

  Future<void> _pickDistrict() async {
    final c = _country.text.trim(), s = _state.text.trim();
    if (c.isEmpty || s.isEmpty) return;
    final v = await _picker<_District>(
      context.l10n.t('form.select.district'),
      _byCountryState[c]![s]!,
          (d) => d.name,
    );
    if (v != null && v.name != _district.text) {
      setState(() {
        _district.text = v.name;
        _lat.text = v.lat?.toString() ?? '';
        _lon.text = v.lon?.toString() ?? '';
      });
    }
  }

  Future<T?> _picker<T>(String title, List<T> items, String Function(T) label) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) {
        var filtered = List<T>.from(items);
        String q = '';
        void apply() {
          final lq = q.toLowerCase().trim();
          filtered = lq.isEmpty
              ? List<T>.from(items)
              : items.where((e) => label(e).toLowerCase().contains(lq)).toList();
        }

        apply();
        final bottom = MediaQuery.of(ctx).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, bottom + 16),
          child: StatefulBuilder(
            builder: (_, setS) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    border: const OutlineInputBorder(),
                    labelText: context.l10n.t('common.search'),
                  ),
                  onChanged: (v) {
                    q = v;
                    setS(apply);
                  },
                ),
                const SizedBox(height: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 360),
                  child: filtered.isEmpty
                      ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(context.l10n.t('results.none')),
                    ),
                  )
                      : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (_, i) => ListTile(
                      title: Text(label(filtered[i])),
                      onTap: () => Navigator.pop(ctx, filtered[i]),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // -------------------- History --------------------

  Future<void> _openHistory() async {
    final picked = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(builder: (_) => const _HistoryPage()),
    );
    if (!mounted || picked == null) return;

    final bd = BirthData.fromJson(picked);
    // Update provider for Tabs and prefill this form
    ref.read(birthDataProvider.notifier).state = bd;
    _prefillFrom(bd);

    // Jump straight to Tabs
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const HoroscopeTabsScreen()),
    );
  }

  // -------------------- Build --------------------

  @override
  Widget build(BuildContext context) {
    final border = const OutlineInputBorder();
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.t('form.title')),
        actions: [
          IconButton(
            tooltip: context.l10n.t('common.history'),
            icon: const Icon(Icons.history),
            onPressed: _openHistory,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: context.l10n.t('form.name'),
                border: border,
              ),
              validator: _req,
            ),
            const SizedBox(height: 12),
            TextFormField(
              readOnly: true,
              controller: TextEditingController(
                text: _dob == null
                    ? ''
                    : '${_dob!.year}-${_dob!.month.toString().padLeft(2, '0')}-${_dob!.day.toString().padLeft(2, '0')}',
              ),
              decoration: InputDecoration(
                labelText: context.l10n.t('form.hint.date'),
                hintText: context.l10n.t('form.hint.date'),
                border: border,
              ),
              onTap: _pickDob,
              validator: (_) => _dob == null ? context.l10n.t('common.required') : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              readOnly: true,
              controller: TextEditingController(
                text: _tob == null ? '' : _tob!.format(context),
              ),
              decoration: InputDecoration(
                labelText: context.l10n.t('form.hint.time'),
                hintText: context.l10n.t('form.hint.time'),
                border: border,
              ),
              onTap: _pickTob,
              validator: (_) => _tob == null ? context.l10n.t('common.required') : null,
            ),
            const SizedBox(height: 20),

            Text(context.l10n.t('form.location'), style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (_loadingLoc)
              Text(context.l10n.t('form.loading.locations'))
            else if (_loadErr != null)
              Text(_loadErr!, style: TextStyle(color: Theme.of(context).colorScheme.error))
            else ...[
                _PickerField(
                  label: context.l10n.t('form.country'),
                  controller: _country,
                  onTap: _pickCountry,
                  validator: _req,
                ),
                const SizedBox(height: 12),
                _PickerField(
                  label: context.l10n.t('form.state'),
                  controller: _state,
                  onTap: _pickState,
                  enabled: _country.text.isNotEmpty,
                  validator: _req,
                ),
                const SizedBox(height: 12),
                _PickerField(
                  label: context.l10n.t('form.district'),
                  controller: _district,
                  onTap: _pickDistrict,
                  enabled: _state.text.isNotEmpty,
                  validator: _req,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _lat,
                        keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[-0-9.]'))],
                        decoration: InputDecoration(
                          labelText: context.l10n.t('form.latitude'),
                          border: const OutlineInputBorder(),
                          helperText: context.l10n.t('common.editable'),
                        ),
                        validator: _numOrEmpty,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _lon,
                        keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[-0-9.]'))],
                        decoration: InputDecoration(
                          labelText: context.l10n.t('form.longitude'),
                          border: const OutlineInputBorder(),
                          helperText: context.l10n.t('common.editable'),
                        ),
                        validator: _numOrEmpty,
                      ),
                    ),
                  ],
                ),
              ],

            const SizedBox(height: 24),
            FilledButton(
              onPressed: () async {
                if (!_formKey.currentState!.validate()) return;
                final bd = BirthData(
                  name: _name.text.trim(),
                  dob: _dob!,
                  tob: _tob!,
                  country: _country.text.trim(),
                  state: _state.text.trim(),
                  district: _district.text.trim(),
                  lat: double.tryParse(_lat.text.trim().isEmpty ? 'nan' : _lat.text.trim()),
                  lon: double.tryParse(_lon.text.trim().isEmpty ? 'nan' : _lon.text.trim()),
                );

                // Save to provider + persist automatically
                ref.read(birthDataProvider.notifier).state = bd;
                await LocalStore.saveBirth(bd.toJson());

                // To tabs
                if (mounted) {
                  if (widget.onSubmitted != null) {
                    widget.onSubmitted!.call();
                  } else {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const HoroscopeTabsScreen()),
                    );
                  }
                }
              },
              child: Text(context.l10n.t('common.submit')),
            ),
          ],
        ),
      ),
    );
  }

  String? _req(String? v) => (v == null || v.trim().isEmpty) ? context.l10n.t('common.required') : null;
  String? _numOrEmpty(String? v) {
    final t = v?.trim() ?? '';
    if (t.isEmpty) return null;
    return double.tryParse(t) == null ? context.l10n.t('common.invalidNumber') : null;
  }
}

// -------------------- History Page (inline) --------------------

// -------------------- History Page (inline) --------------------

class _HistoryPage extends StatefulWidget {
  const _HistoryPage();

  @override
  State<_HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<_HistoryPage> {
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;
  String? _err;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _err = null;
    });
    try {
      final list = await LocalStore.loadHistoryRaw(limit: 10);
      setState(() {
        _items = list;
      });
    } catch (e) {
      setState(() => _err = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _fmtDate(Map<String, dynamic> j) {
    try {
      final dt = DateTime.parse(j['dob'] as String);
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return '-';
    }
  }

  Future<void> _deleteAt(int index) async {
    final item = _items[index];
    await LocalStore.deleteBirthFromHistory(item);
    if (!mounted) return;
    setState(() {
      _items.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.t('snackbar.entryDeleted'))),
    );
  }

  Future<void> _clearAll() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(context.l10n.t('history.clear.confirm.title')),
        content: Text(context.l10n.t('history.clear.confirm.body')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.t('common.cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.t('common.clear')),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await LocalStore.clearHistory();
    if (!mounted) return;
    setState(() => _items.clear());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.t('history.title')),
        actions: [
          if (_items.isNotEmpty)
            IconButton(
              tooltip: context.l10n.t('history.clearAll'),
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: _clearAll,
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (_err != null)
          ? Center(child: Text('${context.l10n.t('common.error')}: $_err'))
          : (_items.isEmpty)
          ? Center(child: Text(context.l10n.t('history.none')))
          : RefreshIndicator(
        onRefresh: _load,
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: _items.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (_, i) {
            final j = _items[i];
            final subtitle = [
              _fmtDate(j),
              if ((j['district'] ?? '').toString().isNotEmpty) j['district'],
              if ((j['state'] ?? '').toString().isNotEmpty) j['state'],
            ].whereType<String>().where((s) => s.trim().isNotEmpty).join(' • ');

            return Dismissible(
              key: ValueKey(j['_savedAt'] ?? '${j['name']}-${i}'),
              direction: DismissDirection.endToStart,
              background: Container(
                color: Theme.of(context).colorScheme.errorContainer,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              confirmDismiss: (_) async {
                return await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text(context.l10n.t('history.delete.confirm.title')),
                    content: Text(
                      (j['name']?.toString() ?? context.l10n.t('history.delete.confirm.body.fallback')),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(context.l10n.t('common.cancel')),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text(context.l10n.t('common.delete')),
                      ),
                    ],
                  ),
                );
              },
              onDismissed: (_) => _deleteAt(i),
              child: ListTile(
                leading: const Icon(Icons.person_outline),
                title: Text((j['name'] ?? '—').toString()),
                subtitle: Text(subtitle),
                trailing: PopupMenuButton<String>(
                  onSelected: (v) {
                    if (v == 'delete') _deleteAt(i);
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        leading: const Icon(Icons.delete_outline),
                        title: Text(context.l10n.t('common.delete')),
                      ),
                    ),
                  ],
                ),
                onTap: () => Navigator.of(context).pop<Map<String, dynamic>>(j),
              ),
            );
          },
        ),
      ),
    );
  }
}


// -------------------- Helpers for location asset --------------------

class _District {
  final String name;
  final double? lat, lon;
  _District(this.name, this.lat, this.lon);
}

Map<String, Map<String, List<_District>>> _normalizeToCountryStateDistrict(dynamic parsed) {
  final Map<String, Map<String, List<_District>>> map = {};
  String s(dynamic v) => (v ?? '').toString().trim();
  double? d(dynamic v) => v == null ? null : (v is num ? v.toDouble() : double.tryParse(v.toString()));
  void add(String c, String st, String dn, double? la, double? lo) {
    c = s(c).isEmpty ? 'India' : s(c);
    st = s(st).isEmpty ? 'Unknown State' : s(st);
    dn = s(dn).isEmpty ? 'Unknown District' : s(dn);
    map.putIfAbsent(c, () => {});
    map[c]!.putIfAbsent(st, () => []);
    map[c]![st]!.add(_District(dn, la, lo));
  }

  if (parsed is Map<String, dynamic>) {
    if (parsed.containsKey('states')) {
      final country = s(parsed['country']).isEmpty ? 'India' : s(parsed['country']);
      for (final st in (parsed['states'] as List? ?? const [])) {
        final m = (st as Map?)?.cast<String, dynamic>() ?? {};
        final stateName = s(m['state'] ?? m['name']);
        for (final dis in (m['districts'] as List? ?? const [])) {
          final dm = (dis as Map?)?.cast<String, dynamic>() ?? {};
          add(
            country,
            stateName,
            s(dm['name'] ?? dm['district']),
            d(dm['latitude'] ?? dm['lat'] ?? dm['Latitude']),
            d(dm['longitude'] ?? dm['lon'] ?? dm['Longitude'] ?? dm['lng']),
          );
        }
      }
    } else {
      for (final e in parsed.entries) {
        final country = s(e.key);
        final val = (e.value as Map?)?.cast<String, dynamic>() ?? {};
        for (final st in (val['states'] as List? ?? const [])) {
          final m = (st as Map?)?.cast<String, dynamic>() ?? {};
          final stateName = s(m['state'] ?? m['name']);
          for (final dis in (m['districts'] as List? ?? const [])) {
            final dm = (dis as Map?)?.cast<String, dynamic>() ?? {};
            add(
              country,
              stateName,
              s(dm['name'] ?? dm['district']),
              d(dm['latitude'] ?? dm['lat'] ?? dm['Latitude']),
              d(dm['longitude'] ?? dm['lon'] ?? dm['Longitude'] ?? dm['lng']),
            );
          }
        }
      }
    }
  } else if (parsed is List) {
    for (final item in parsed) {
      final im = (item as Map?)?.cast<String, dynamic>() ?? {};
      final country = s(im['country']).isEmpty ? 'India' : s(im['country']);
      final stateName = s(im['state'] ?? im['name']);
      for (final dis in (im['districts'] as List? ?? const [])) {
        final dm = (dis as Map?)?.cast<String, dynamic>() ?? {};
        add(
          country,
          stateName,
          s(dm['name'] ?? dm['district']),
          d(dm['latitude'] ?? dm['lat'] ?? dm['Latitude']),
          d(dm['longitude'] ?? dm['lon'] ?? dm['Longitude'] ?? dm['lng']),
        );
      }
    }
  } else {
    throw Exception('Unsupported JSON structure');
  }

  for (final c in map.keys) {
    for (final st in map[c]!.keys) {
      final seen = <String>{};
      final unique = <_District>[];
      for (final d0 in map[c]![st]!) {
        if (seen.add(d0.name)) unique.add(d0);
      }
      unique.sort((a, b) => a.name.compareTo(b.name));
      map[c]![st] = unique;
    }
  }
  return map;
}

class _PickerField extends StatelessWidget {
  const _PickerField({
    required this.label,
    required this.controller,
    required this.onTap,
    this.enabled = true,
    this.validator,
  });
  final String label;
  final TextEditingController controller;
  final VoidCallback onTap;
  final bool enabled;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      enabled: enabled,
      validator: validator,
      decoration: const InputDecoration(border: OutlineInputBorder()).copyWith(
        labelText: label,
        hintText: context.l10n.t('form.tapSelect'),
        suffixIcon: const Icon(Icons.arrow_drop_down),
      ),
      onTap: enabled ? onTap : null,
    );
  }
}
