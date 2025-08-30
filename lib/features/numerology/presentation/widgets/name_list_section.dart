import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle, ClipboardData, Clipboard;

/// NameListSection
/// - Boy/Girl segmented selector
/// - 27 Tamil நச்சத்திரங்கள் as chips
/// - Names list loaded from assets/names/natchathiram_names_ta.json
class NameListSection extends StatefulWidget {
  const NameListSection({super.key});

  @override
  State<NameListSection> createState() => _NameListSectionState();
}

class _NameListSectionState extends State<NameListSection> {
  final _searchCtrl = TextEditingController();

  NameListStore? _store;
  String? _error;

  // Default selections
  bool _isBoy = true;
  String _selectedStar = _starsTa.first;

  static const String _assetPath = 'assets/names/natchathiram_names_ta.json';

  // 27 Tamil natchathirams (common spellings)
  static const List<String> _starsTa = [
    'அஸ்வினி', 'பரணி', 'கார்த்திகை', 'ரோகிணி', 'மிருகசீரிடம்',
    'திருவாதிரை', 'புனர்பூசம்', 'பூசம்', 'ஆயில்யம்', 'மகம்',
    'பூரம்', 'உத்திரம்', 'ஹஸ்தம்', 'சித்திரை', 'சுவாதி',
    'விசாகம்', 'அனுஷம்', 'கேட்டை', 'மூலம்', 'பூராடம்',
    'உத்திராடம்', 'திருவோணம்', 'அவிட்டம்', 'சதயம்', 'பூரட்டாதி',
    'உத்திரட்டாதி', 'ரேவதி',
  ];

  @override
  void initState() {
    super.initState();
    _load();
    _searchCtrl.addListener(() => setState(() {}));
  }

  Future<void> _load() async {
    setState(() {
      _store = null;
      _error = null;
    });
    try {
      final raw = await rootBundle.loadString(_assetPath);
      final data = json.decode(raw);
      setState(() => _store = NameListStore.fromJson(data));
    } catch (e) {
      setState(() => _error = 'பெயர் பட்டியல் கோப்பை ஏற்ற முடியவில்லை');
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ready = _store != null;

    final names = ready
        ? _store!.namesFor(_selectedStar, isBoy: _isBoy)
        : const <String>[];

    final query = _searchCtrl.text.trim();
    final filtered = query.isEmpty
        ? names
        : names.where((n) => n.contains(query)).toList();

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.list_alt, size: 20),
              const SizedBox(width: 8),
              Text(
                'பெயர் பட்டியல் (Name List)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              if (!ready)
                const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            ]),

            const SizedBox(height: 12),

            // Boy/Girl toggle
            Row(
              children: [
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: true, label: Text('Boy')),
                    ButtonSegment(value: false, label: Text('Girl')),
                  ],
                  selected: {_isBoy},
                  onSelectionChanged: (s) => setState(() => _isBoy = s.first),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Search name…',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // 27 natchathiram chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _starsTa.map((star) {
                final selected = star == _selectedStar;
                return ChoiceChip(
                  label: Text(star),
                  selected: selected,
                  onSelected: (_) => setState(() => _selectedStar = star),
                );
              }).toList(),
            ),

            const SizedBox(height: 12),

            if (_error != null) ...[
              Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 8),
            ],

            if (!ready)
              Text('பெயர் தரவை ஏற்று வருகிறது…', style: TextStyle(color: Colors.grey.shade600))
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$_selectedStar — ${_isBoy ? "ஆண் குழந்தை" : "பெண் குழந்தை"} பெயர்கள் (${filtered.length})',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  if (filtered.isEmpty)
                    Text('இந்த தேர்வுக்கு பெயர்கள் கிடைக்கவில்லை.', style: TextStyle(color: Colors.grey.shade600)),
                  if (filtered.isNotEmpty)
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const Divider(height: 12),
                      itemBuilder: (_, i) {
                        final name = filtered[i];
                        return ListTile(
                          dense: true,
                          title: Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                          trailing: IconButton(
                            icon: const Icon(Icons.copy),
                            tooltip: 'Copy',
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: name));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Copied: $name')),
                              );
                            },
                          ),
                        );
                      },
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/* --------------------------- Store & Model --------------------------- */

class NameListStore {
  final Map<String, NameBucket> byStar; // key = Tamil star label

  NameListStore({required this.byStar});

  factory NameListStore.fromJson(Map json) {
    final map = <String, NameBucket>{};
    final stars = json['natchathirams'];
    if (stars is Map) {
      stars.forEach((k, v) {
        if (v is Map) {
          map[k.toString()] = NameBucket.fromJson(v);
        }
      });
    }
    return NameListStore(byStar: map);
  }

  List<String> namesFor(String starTa, {required bool isBoy}) {
    final bucket = byStar[starTa];
    if (bucket == null) return const [];
    return isBoy ? bucket.boy : bucket.girl;
  }
}

class NameBucket {
  final List<String> boy;
  final List<String> girl;

  NameBucket({required this.boy, required this.girl});

  factory NameBucket.fromJson(Map json) {
    List<String> _arr(dynamic x) =>
        (x is List) ? x.whereType<String>().toList() : const <String>[];
    return NameBucket(
      boy: _arr(json['boy']),
      girl: _arr(json['girl']),
    );
  }
}
