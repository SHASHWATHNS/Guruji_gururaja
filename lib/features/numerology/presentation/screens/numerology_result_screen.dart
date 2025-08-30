import 'package:flutter/material.dart';
import '../../domain/entities/numerology_input.dart';
import '../widgets/numerology_jadagarin_vivaram_tab.dart';
import '../widgets/numerology_kattangal_tab.dart';

class NumerologyResultScreen extends StatelessWidget {
  final NumerologyInput input;
  const NumerologyResultScreen({super.key, required this.input});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Numerology'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.person), text: 'Jadagarin Vivaram'),
              Tab(icon: Icon(Icons.grid_4x4), text: 'Kattangal'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            NumerologyJadagarinVivaramTab(input: input),
            NumerologyKattangalTab(input: input),
          ],
        ),
      ),
    );
  }
}
