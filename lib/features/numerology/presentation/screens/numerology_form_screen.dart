import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/numerology_form_provider.dart';
import 'numerology_result_screen.dart';

class NumerologyFormScreen extends ConsumerStatefulWidget {
  const NumerologyFormScreen({super.key});
  @override
  ConsumerState<NumerologyFormScreen> createState() => _NumerologyFormScreenState();
}

class _NumerologyFormScreenState extends ConsumerState<NumerologyFormScreen> {
  late final TextEditingController _nameCtrl;

  @override
  void initState() {
    super.initState();
    final st = ref.read(numerologyFormProvider);
    _nameCtrl = TextEditingController(text: st.name);
    _nameCtrl.addListener(() {
      ref.read(numerologyFormProvider.notifier).setName(_nameCtrl.text);
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDob() async {
    final formSt = ref.read(numerologyFormProvider);
    final noti = ref.read(numerologyFormProvider.notifier);
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
    final input = ref.read(numerologyFormProvider.notifier).buildInput();
    if (input == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => NumerologyResultScreen(input: input)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formSt = ref.watch(numerologyFormProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Numerology – Birth Details')),
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
    final muted =
    Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.grey[700]);
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
