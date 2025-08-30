class AntarDasa {
  final String name;
  final DateTime start;
  final DateTime end;
  AntarDasa({required this.name, required this.start, required this.end});
}

class MahaDasa {
  final String graha;
  final DateTime start;
  final DateTime end;
  final List<AntarDasa> antars;
  MahaDasa({required this.graha, required this.start, required this.end, required this.antars});
}

class DasaSnapshot {
  final String currentMaha;
  final String currentAntar;
  final DateTime from;
  final DateTime to;
  DasaSnapshot({required this.currentMaha, required this.currentAntar, required this.from, required this.to});
}

class DasaTree {
  final DasaSnapshot snapshot;
  final List<MahaDasa> table;
  DasaTree({required this.snapshot, required this.table});
}
