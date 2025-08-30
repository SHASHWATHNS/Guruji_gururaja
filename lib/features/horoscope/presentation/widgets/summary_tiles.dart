import 'package:flutter/material.dart';

class SummaryItem {
  final String title;
  final String value;
  final String? subtitle;
  final IconData? icon;
  SummaryItem({required this.title, required this.value, this.subtitle, this.icon});
}

class SummaryTiles extends StatelessWidget {
  final List<SummaryItem> items;
  const SummaryTiles({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: items.map((it) => _tile(context, it)).toList(),
    );
  }

  Widget _tile(BuildContext context, SummaryItem it) {
    final theme = Theme.of(context);
    final w = MediaQuery.of(context).size.width;
    final boxW = w > 900 ? (w - 16*2 - 12*2) / 3 : w > 600 ? (w - 16*2 - 12) / 2 : w - 16*2;

    return SizedBox(
      width: boxW,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.brown.shade200),
          color: Colors.brown.shade50,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (it.icon != null) ...[
              Icon(it.icon, size: 22, color: Colors.brown.shade600),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(it.title, style: theme.textTheme.labelLarge),
                  const SizedBox(height: 2),
                  Text(it.value, style: theme.textTheme.titleMedium),
                  if (it.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(it.subtitle!, style: theme.textTheme.bodySmall?.copyWith(color: Colors.brown[700])),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
