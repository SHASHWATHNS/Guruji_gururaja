import 'package:flutter/material.dart';
import '../../domain/entities/planet_entity.dart';

class GrahaCards extends StatelessWidget {
  final List<PlanetEntity> planets;
  const GrahaCards({super.key, required this.planets});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, c) {
        final w = c.maxWidth;
        final cross = w > 900 ? 3 : w > 600 ? 2 : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: planets.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cross,
            mainAxisExtent: 120,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (_, i) => _GrahaCard(p: planets[i]),
        );
      },
    );
  }
}

class _GrahaCard extends StatelessWidget {
  final PlanetEntity p;
  const _GrahaCard({required this.p});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.brown.shade200),
        color: Colors.brown.shade50,
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(radius: 14, child: Text(p.name.isNotEmpty ? p.name[0] : '?')),
              const SizedBox(width: 8),
              Text(p.name, style: theme.textTheme.titleMedium),
              const Spacer(),
              if (p.retro)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: Colors.red.shade100,
                  ),
                  child: const Text('Retro', style: TextStyle(fontSize: 12)),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            runSpacing: 6,
            children: [
              _pill('Sign', p.sign.isEmpty ? '-' : p.sign),
              _pill('Deg', p.degInSign.toStringAsFixed(2)),
              _pill('House', p.house == 0 ? '-' : p.house.toString()),
              if (p.nakshatra.isNotEmpty) _pill('Naksh.', p.nakshatra),
              if (p.pada > 0) _pill('Pada', p.pada.toString()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pill(String k, String v) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.brown.shade300),
        color: Colors.white,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$k: ', style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(v),
        ],
      ),
    );
  }
}
