import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/panchanga_providers.dart';

class MonthCalendarView extends ConsumerWidget {
  const MonthCalendarView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grid = ref.watch(monthGridProvider);
    final month = ref.watch(monthAnchorProvider);

    return Column(
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () {
                final m = DateTime(month.year, month.month - 1, 1);
                ref.read(monthAnchorProvider.notifier).state = m;
              },
            ),
            Expanded(
              child: Center(
                child: Text(
                  // YYYY-MM
                  '${month.year}-${month.month.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () {
                final m = DateTime(month.year, month.month + 1, 1);
                ref.read(monthAnchorProvider.notifier).state = m;
              },
            ),
          ],
        ),
        const SizedBox(height: 6),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: grid.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1.1,
          ),
          itemBuilder: (context, i) {
            final c = grid[i];
            final textStyle = TextStyle(
              color: c.inCurrentMonth ? Colors.black : Colors.black38,
              fontWeight: c.isToday ? FontWeight.w800 : FontWeight.w600,
            );
            return InkWell(
              onTap: () {
                // set the chosen date and go to day view
                ref.read(selectedDateProvider.notifier).state =
                    DateTime(c.date.year, c.date.month, c.date.day);
                context.pushNamed('panchanga-day');
              },
              child: Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: c.isToday ? Colors.green.shade50 : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black12),
                ),
                child: Center(child: Text('${c.date.day}', style: textStyle)),
              ),
            );
          },
        ),
      ],
    );
  }
}
