import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/month_calendar_view.dart';
import '../widgets/panchanga_header_card.dart';
import '../providers/panchanga_providers.dart';

class PanchangaMonthScreen extends ConsumerWidget {
  const PanchangaMonthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(monthAnchorProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('மாத காலண்டர் பஞ்சாங்கம்'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            PanchangaHeaderCard(date: month, subtitle: '-'),
            const SizedBox(height: 12),
            const MonthCalendarView(),
          ],
        ),
      ),
    );
  }
}
