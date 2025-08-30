import 'package:flutter/material.dart';
import '../../domain/entities/planet_entity.dart';

/// Simple South-Indian box chart (12 houses).
/// Places planets into houses using PlanetEntity.house (1..12).
/// Shows Ascendant label if present.
class SouthIndianRasiChart extends StatelessWidget {
  final List<PlanetEntity> planets;
  final String? language; // 'en' or 'ta' (future switch)
  const SouthIndianRasiChart({super.key, required this.planets, this.language = 'en'});

  static const _gridOrder = <int>[
    12, 1, 2, 3,
    11, 10, 9, 4,
    8, 7, 6, 5,
  ];

  static const _abbrEn = {
    'Ascendant': 'Asc',
    'Sun': 'Su', 'Moon': 'Mo', 'Mars': 'Ma', 'Mercury': 'Me',
    'Jupiter': 'Ju', 'Venus': 'Ve', 'Saturn': 'Sa', 'Rahu': 'Ra', 'Ketu': 'Ke',
  };

  static const _abbrTa = {
    'Ascendant': 'லக்',
    'Sun': 'சு', 'Moon': 'சந்', 'Mars': 'செ', 'Mercury': 'பு',
    'Jupiter': 'கு', 'Venus': 'சுக்', 'Saturn': 'சனி', 'Rahu': 'ரா', 'Ketu': 'கே',
  };

  @override
  Widget build(BuildContext context) {
    // Group planets by house
    final byHouse = <int, List<PlanetEntity>>{};
    for (final p in planets) {
      final h = p.house <= 0 ? 1 : p.house;
      byHouse.putIfAbsent(h, () => []).add(p);
    }

    // quick ascendant flag
    final hasAsc = planets.any((p) => p.name.toLowerCase().contains('asc'));

    return AspectRatio(
      aspectRatio: 1, // square chart
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.brown.shade400, width: 2),
        ),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: 12,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
          ),
          itemBuilder: (_, idx) {
            final houseNo = _gridOrder[idx];
            final items = byHouse[houseNo] ?? const [];
            return _HouseBox(
              houseNo: houseNo,
              tags: items.map((p) => _abbr(p.name)).toList(),
              highlight: hasAsc && items.any((p) => p.name.toLowerCase().contains('asc')),
            );
          },
        ),
      ),
    );
  }

  String _abbr(String name) {
    final map = (language == 'ta') ? _abbrTa : _abbrEn;
    return map[name] ?? name.substring(0, name.length < 3 ? name.length : 2);
  }
}

class _HouseBox extends StatelessWidget {
  final int houseNo;
  final List<String> tags;
  final bool highlight;
  const _HouseBox({required this.houseNo, required this.tags, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: Colors.brown.shade300, width: 1),
          bottom: BorderSide(color: Colors.brown.shade300, width: 1),
        ),
        color: highlight ? Colors.brown.shade100 : null,
      ),
      padding: const EdgeInsets.all(6),
      child: Stack(
        children: [
          Positioned(
            top: 2,
            right: 4,
            child: Text(
              '$houseNo',
              style: TextStyle(fontSize: 10, color: Colors.brown.shade600),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 6,
              runSpacing: 4,
              children: tags.map((t) => _pill(t)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.brown.shade400),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12)),
    );
  }
}
