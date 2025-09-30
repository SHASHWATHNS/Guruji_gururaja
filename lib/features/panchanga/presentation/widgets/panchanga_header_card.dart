import 'package:flutter/material.dart';

String formatDateCard(DateTime d) => '${d.day}-${d.month}-${d.year}';

class PanchangaHeaderCard extends StatelessWidget {
  const PanchangaHeaderCard({
    super.key,
    required this.date,
    required this.subtitle, // e.g., weekday or month name
  });

  final DateTime date;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1BAE6E), Color(0xFF0C8F5A)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            subtitle.isEmpty ? '-' : subtitle,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18),
          ),
          const SizedBox(height: 6),
          Text(
            formatDateCard(date),
            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}
