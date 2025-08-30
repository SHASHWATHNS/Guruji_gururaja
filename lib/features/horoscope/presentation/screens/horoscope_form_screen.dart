// lib/features/horoscope/presentation/screens/horoscope_form_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/horoscope_form_provider.dart';
import '../providers/place_picker_provider.dart';
import 'horoscope_result_screen.dart';

class HoroscopeFormScreen extends ConsumerStatefulWidget {
  const HoroscopeFormScreen({super.key});
  @override
  ConsumerState<HoroscopeFormScreen> createState() => _HoroscopeFormScreenState();
}

class _HoroscopeFormScreenState extends ConsumerState<HoroscopeFormScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _tobCtrl;

  @override
  void initState() {
    super.initState();
    final st = ref.read(horoscopeFormProvider);
    _nameCtrl = TextEditingController(text: st.name);
    _tobCtrl = TextEditingController(text: st.tob24h);

    _nameCtrl.addListener(() {
      ref.read(horoscopeFormProvider.notifier).setName(_nameCtrl.text);
    });
    _tobCtrl.addListener(() {
      ref.read(horoscopeFormProvider.notifier).setTob(_tobCtrl.text);
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _tobCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDob() async {
    final formSt = ref.read(horoscopeFormProvider);
    final noti = ref.read(horoscopeFormProvider.notifier);
    final now = DateTime.now();
    final initial = formSt.dob ?? DateTime(now.year - 25, now.month, now.day);
    final d = await showDatePicker(
      context: context,
      firstDate: DateTime(1800, 1, 1),
      lastDate: now,
      initialDate: initial,
    );
    if (d != null) noti.setDob(d);
  }

  void _submit() {
    final input = ref.read(horoscopeFormProvider.notifier).buildInput();
    if (input == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => HoroscopeResultScreen(input: input)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formSt = ref.watch(horoscopeFormProvider);
    final formNoti = ref.read(horoscopeFormProvider.notifier);

    final placeSt = ref.watch(placePickerProvider);
    final placeNoti = ref.read(placePickerProvider.notifier);

    final selectedPlace = placeNoti.selected;

    // Unique, sorted states & guarded value
    final states = placeNoti.states.toSet().toList()..sort();
    final stateValue = states.contains(placeSt.state) ? placeSt.state : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Horoscope – Birth Details')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Name
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: 'Name'),
          ),

          const SizedBox(height: 12),

          // DOB
          _TileRow(
            label: 'Date of Birth',
            value: formSt.dob == null
                ? 'Select'
                : '${formSt.dob!.day.toString().padLeft(2, '0')}-'
                '${formSt.dob!.month.toString().padLeft(2, '0')}-'
                '${formSt.dob!.year}',
            onTap: _pickDob,
          ),

          const SizedBox(height: 12),

          // TOB + Unknown toggle
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _tobCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Time of Birth (24h, HH:mm)',
                    hintText: '14:25',
                  ),
                  keyboardType: TextInputType.datetime,
                  enabled: !formSt.unknownTime,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Unknown time'),
                  Switch(
                    value: formSt.unknownTime,
                    onChanged: formNoti.toggleUnknown,
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // State → District pickers
          const Text('Birthplace'),
          const SizedBox(height: 6),

          // ===== STATE DROPDOWN (guarded) =====
          DropdownButtonFormField<String>(
            value: stateValue,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'State',
              border: OutlineInputBorder(),
            ),
            items: states
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: (s) {
              if (s == null) return;
              placeNoti.selectState(s); // clears district in notifier
            },
          ),

          const SizedBox(height: 10),

          // ===== DISTRICT DROPDOWN (guarded) =====
          if (placeSt.state != null)
            Builder(builder: (_) {
              final districts = placeNoti
                  .districtsOf(placeSt.state)
                  .map((d) => d.trim())
                  .toSet()
                  .toList()
                ..sort();

              final districtValue = (placeSt.district != null &&
                  districts.contains(placeSt.district!.trim()))
                  ? placeSt.district!.trim()
                  : null;

              return DropdownButtonFormField<String>(
                value: districtValue,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'District',
                  border: OutlineInputBorder(),
                ),
                items: districts
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (d) {
                  if (d == null) return;
                  // 1) update picker state
                  placeNoti.selectDistrict(d);

                  // 2) push into the form provider (safe: event handler)
                  final sel = placeNoti.selected;
                  if (sel != null) {
                    formNoti.setPlace(
                      PlacePick(
                        label: '${sel.district}, ${sel.state}',
                        lat: sel.lat,
                        lng: sel.lng,
                        tzid: sel.tzid,
                      ),
                    );
                  }
                },
              );
            }),

          if (selectedPlace != null) ...[
            const SizedBox(height: 8),
            Text(
              'Selected: ${selectedPlace.district}, ${selectedPlace.state}\n'
                  'Lat: ${selectedPlace.lat}, Lng: ${selectedPlace.lng}, TZ: ${selectedPlace.tzid}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],

          const SizedBox(height: 20),

          if (formSt.error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(formSt.error!, style: const TextStyle(color: Colors.red)),
            ),

          FilledButton(onPressed: _submit, child: const Text('Continue')),
        ],
      ),
    );
  }
}

class _TileRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  const _TileRow({
    required this.label,
    required this.value,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.grey[700]);
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Text(label),
            const Spacer(),
            Text(value, style: muted),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
