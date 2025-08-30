import 'package:flutter/material.dart';
import '../../domain/entities/birth_input.dart';
import 'tabs/jadagarin_vivaram_tab.dart';
import 'tabs/kattangal_tab.dart';
import 'tabs/dasa_buthi_tab.dart';

class HoroscopeResultScreen extends StatelessWidget {
  final BirthInput input;
  const HoroscopeResultScreen({super.key, required this.input});

  static const _tabs = [
    ('Jadagarin Vivaram', Icons.person),
    ('Kattangal', Icons.wb_sunny),
    ('Dasa_Buthi', Icons.timeline),
    ('Pirapu + Kochaaram', Icons.public),
    ('Baavaga Attavanai', Icons.table_chart),
    ('Yogangal', Icons.star),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Horoscope'),
          bottom: TabBar(
            isScrollable: true,
            tabs: _tabs.map((t) => Tab(text: t.$1, icon: Icon(t.$2))).toList(),
          ),
        ),
        body: TabBarView(
          children: [
            JadagarinVivaramTab(input: input),
            KattangalTab(input: input),
            DasaButhiTab(input: input),            // <-- use it here
            _PlaceholderTab('Natal + Transit', input),
            _PlaceholderTab('House Table', input),
            _PlaceholderTab('Yogas', input),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  final String title;
  final BirthInput input;
  const _PlaceholderTab(this.title, this.input);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        Text('Name: ${input.name}'),
        Text('DOB: ${input.dobLocal.toIso8601String().split("T").first}'),
        Text('TOB: ${input.tob24h ?? "(unknown)"}'),
        Text('Place: ${input.placeLabel}'),
        Text('Lat/Lng: ${input.lat}, ${input.lng}'),
        Text('TZ: ${input.tzid}'),
        const SizedBox(height: 16),
        const Text('→ Data will load here once we wire the APIs.'),
      ],
    );
  }
}
