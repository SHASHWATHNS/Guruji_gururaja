import 'package:flutter/material.dart';
import '../../../horoscope/presentation/widgets/south_indian_chart.dart';
import '../../domain/entities/numerology_input.dart';
import 'package:flutter/material.dart';
import '../../../horoscope/presentation/widgets/south_indian_chart.dart'; // <-- fixed path


class NumerologyKattangalTab extends StatelessWidget {
  final NumerologyInput input;
  const NumerologyKattangalTab({super.key, required this.input});

  @override
  Widget build(BuildContext context) {
    // demo data (replace with API later)
    final demoRasi = <int, List<String>>{
      1: ['சூரி'], 2: ['செவ்'], 3: ['புத்'],
      4: [], 5: ['சுக்ர'], 6: [],
      7: ['சனி'], 8: [], 9: ['கேது'],
      10: [], 11: ['ராகு'], 12: ['குரு'],
    };

    final demoNavamsa = <int, List<String>>{
      1: ['Su'], 2: ['Ma'], 3: ['Me'],
      4: ['Mo'], 5: [], 6: ['Ju'],
      7: [], 8: ['Sa'], 9: [],
      10: [], 11: ['Ra'], 12: ['Ke'],
    };

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SouthIndianChart(
          title: 'ராசி கட்டம் (Rāsi Kattam)',
          houses: demoRasi,
          accent: const Color(0xFF8E6C3A),
          startAtPosition: 1, // <-- 2nd top box is House 1
        ),
        const SizedBox(height: 16),
        SouthIndianChart(
          title: 'நவாம்சம் கட்டம் (Navamsam Kattam)',
          houses: demoNavamsa,
          accent: const Color(0xFF4A6FA5),
          startAtPosition: 1, // <-- same rotation
        ),
      ],
    );
  }
}
