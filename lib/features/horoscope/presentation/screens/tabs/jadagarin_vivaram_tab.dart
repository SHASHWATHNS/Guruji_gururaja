import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/birth_input.dart';
import '../../providers/jadagarin_summary_provider.dart';
import '../../widgets/simple_kv_table.dart';

class JadagarinVivaramTab extends ConsumerStatefulWidget {
  final BirthInput input;
  const JadagarinVivaramTab({super.key, required this.input});

  @override
  ConsumerState<JadagarinVivaramTab> createState() => _JadagarinVivaramTabState();
}

class _JadagarinVivaramTabState extends ConsumerState<JadagarinVivaramTab> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(jSummaryProvider.notifier).load(widget.input));
  }

  @override
  Widget build(BuildContext context) {
    final st = ref.watch(jSummaryProvider);

    if (st is JLoading) {
      return const Center(child: Text('கணக்கிடப்படுகிறது…'));
    }
    if (st is JError) {
      return Center(child: Text('பிழை: ${st.message}', style: const TextStyle(color: Colors.red)));
    }
    if (st is JReady) {
      final s = st.summary;
      final rows = <(String,String)>[
        ('பெயர்', s.name),
        ('பிறந்த தேதி', s.dob),
        ('பிறந்த நேரம்', s.tob),
        ('பிறந்த ஊர்', s.city),
        ('நாள்', s.weekdayTa),
        ('இந்து நாள்', s.hinduDayTa),
        ('வயது', s.age),
        ('லக்னம்', s.lagnam),
        ('ராசி', s.raasi),
        ('நட்சத்திரம்', s.star),
        ('திதி', s.thithi),
        ('திதி சூனியம்', s.thithiSoonyam),
        ('யோகம்', s.yogam),
        ('யோகி, அவயோகி', s.yogiAvaYogi),
        ('கரணம்', s.karanam),
        ('தமிழ் மாதம்', s.tamilMaadham),
        ('தமிழ் வருடம்', s.tamilVarudam),
      ];
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SimpleKVTable(rows: rows),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}
