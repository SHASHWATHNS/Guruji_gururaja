import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/panchanga.dart';
import '../viewmodels/panchanga_view_model.dart';

class PanchangaScreen extends ConsumerWidget {
  const PanchangaScreen({super.key});

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final st = ref.watch(panchangaProvider);
    final notifier = ref.read(panchangaProvider.notifier);

    return DefaultTabController(
      length: 6,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.headerBar,
          title: const Text(
            'Akshaya Lagna Paddati',
            style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black),
          ),
          actions: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.share)),
            IconButton(onPressed: () {}, icon: const Icon(Icons.undo)),
          ],
        ),
        body: Column(
          children: [
            // Date navigation row
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: notifier.previousDay,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange[700],
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      child: const Text('PREVIOUS DAY'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final now = DateTime.now();
                        final res = await showDatePicker(
                          context: context,
                          initialDate: st.date,
                          firstDate: DateTime(now.year - 50),
                          lastDate: DateTime(now.year + 50),
                        );
                        if (res != null) notifier.setDate(res);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      child: Text(_fmt(st.date), style: const TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: notifier.nextDay,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange[700],
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      child: const Text('NEXT DAY'),
                    ),
                  ),
                ],
              ),
            ),

            // Orange tab strip (scrollable)
            Container(
              height: 44,
              color: Colors.orange,
              child: const TabBar(
                isScrollable: true,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: [
                  Tab(text: 'Panchanga'),
                  Tab(text: 'Kundali'),
                  Tab(text: 'Hora'),
                  Tab(text: 'Pancha Pakshi'),
                  Tab(text: 'Pancha Tatva'),
                  Tab(text: 'Tatva Character'),
                ],
              ),
            ),

            // Content
            Expanded(
              child: TabBarView(
                children: [
                  _PanchangaTab(st: st),
                  _ComingSoon(label: 'Kundali'),
                  _ComingSoon(label: 'Hora'),
                  _ComingSoon(label: 'Pancha Pakshi'),
                  _ComingSoon(label: 'Pancha Tatva'),
                  _ComingSoon(label: 'Tatva Character'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PanchangaTab extends ConsumerWidget {
  final PanchangaState st;
  const _PanchangaTab({required this.st});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (st.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (st.error != null) {
      return Center(child: Text('Error: ${st.error}', style: const TextStyle(color: Colors.red)));
    }
    if (st.data == null) {
      return const SizedBox.shrink();
    }

    final data = st.data!;
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 20),
      itemCount: data.sections.length,
      itemBuilder: (_, i) {
        final sec = data.sections[i];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (sec.thickDividerBefore) ...[
              const SizedBox(height: 10),
              const Divider(thickness: 2),
              const SizedBox(height: 4),
            ],
            for (final item in sec.items) _PanchangaRow(item: item),
          ],
        );
      },
    );
  }
}

class _PanchangaRow extends StatelessWidget {
  final PanchangaItem item;
  const _PanchangaRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final hasLabel = item.label.trim().isNotEmpty;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasLabel)
            Text(
              item.label,
              style: const TextStyle(
                color: Colors.blue,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          const SizedBox(height: 2),
          Text(
            item.value,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 22,
              height: 1.1,
            ),
          ),
          if (item.timeText != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                item.timeText!,
                style: const TextStyle(color: Colors.black54, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}

class _ComingSoon extends StatelessWidget {
  final String label;
  const _ComingSoon({required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('$label — coming soon',
          style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.black54)),
    );
  }
}
