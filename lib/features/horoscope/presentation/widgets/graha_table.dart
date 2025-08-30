import 'package:flutter/material.dart';
import '../../domain/entities/planet_entity.dart';

class GrahaTable extends StatelessWidget {
  final List<PlanetEntity> planets;
  const GrahaTable({super.key, required this.planets});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Planet')),
          DataColumn(label: Text('Sign')),
          DataColumn(label: Text('Deg')),
          DataColumn(label: Text('House')),
          DataColumn(label: Text('Nakshatra')),
          DataColumn(label: Text('Pada')),
          DataColumn(label: Text('R')),
        ],
        rows: planets.map((p) {
          return DataRow(cells: [
            DataCell(Text(p.name)),
            DataCell(Text(p.sign)),
            DataCell(Text(p.degInSign.toStringAsFixed(2))),
            DataCell(Text(p.house == 0 ? '-' : p.house.toString())),
            DataCell(Text(p.nakshatra)),
            DataCell(Text(p.pada.toString())),
            DataCell(Icon(p.retro ? Icons.check : Icons.close, size: 16)),
          ]);
        }).toList(),
      ),
    );
  }
}
