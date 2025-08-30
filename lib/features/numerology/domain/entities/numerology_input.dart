class NumerologyInput {
  final String name;
  final DateTime dob;

  const NumerologyInput({
    required this.name,
    required this.dob,
  });

  NumerologyInput copyWith({String? name, DateTime? dob}) =>
      NumerologyInput(name: name ?? this.name, dob: dob ?? this.dob);
}
