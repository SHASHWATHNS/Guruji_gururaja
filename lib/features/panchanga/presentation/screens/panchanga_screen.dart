import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/panchanga_providers.dart';
import '../widgets/panchanga_header_card.dart';

class PanchangaScreen extends ConsumerWidget {
  const PanchangaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = ref.watch(selectedDateProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('பஞ்சாங்கம்'), centerTitle: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              PanchangaHeaderCard(date: today, subtitle: '-'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _BigBtn(
                      color: const Color(0xFFF46C6C),
                      icon: Icons.event_available,
                      label: 'நாள் காட்டு',
                      onTap: () => context.pushNamed('panchanga-day'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _BigBtn(
                      color: const Color(0xFF59B96C),
                      icon: Icons.calendar_month,
                      label: 'மாத காட்டு',
                      onTap: () => context.pushNamed('panchanga-month'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BigBtn extends StatelessWidget {
  const _BigBtn({required this.color, required this.icon, required this.label, required this.onTap});
  final Color color; final IconData icon; final String label; final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Ink(
        height: 64,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle), padding: const EdgeInsets.all(8), child: Icon(icon, color: Colors.white)),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
        ]),
      ),
    );
  }
}
