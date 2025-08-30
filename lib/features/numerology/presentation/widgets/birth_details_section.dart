import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/numerology_providers.dart';

class BirthDetailsSection extends ConsumerWidget {
  const BirthDetailsSection({super.key});

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final st = ref.watch(numerologyInputProvider);
    final notifier = ref.read(numerologyInputProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Name', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        // Use TextFormField with initialValue to avoid controller rebuild issues
        TextFormField(
          initialValue: st.name,
          onChanged: notifier.setName,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Enter full name',
          ),
        ),
        const SizedBox(height: 16),
        Text('Date of Birth', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: st.dob,
              firstDate: DateTime(1900),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (picked != null) notifier.setDob(picked);
          },
          child: InputDecorator(
            decoration: const InputDecoration(border: OutlineInputBorder()),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_fmt(st.dob)),
                const Icon(Icons.calendar_month),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // Recompute the two birth-driven tabs
              ref.invalidate(
                numerologySectionProvider(NumerologySection.jadagarinVivaram),
              );
              ref.invalidate(
                numerologySectionProvider(
                    NumerologySection.kattangalLuckyNumbers),
              );
            },
            child: const Text('Continue'),
          ),
        ),
      ],
    );
  }
}
