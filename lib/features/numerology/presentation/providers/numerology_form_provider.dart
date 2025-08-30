import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/numerology_input.dart';

class NumerologyFormState {
  final String name;
  final DateTime? dob;
  final String? error;

  const NumerologyFormState({
    this.name = '',
    this.dob,
    this.error,
  });

  NumerologyFormState copyWith({
    String? name,
    DateTime? dob,
    String? error,
  }) =>
      NumerologyFormState(
        name: name ?? this.name,
        dob: dob ?? this.dob,
        error: error,
      );
}

class NumerologyFormNotifier extends StateNotifier<NumerologyFormState> {
  NumerologyFormNotifier() : super(const NumerologyFormState());

  void setName(String v) => state = state.copyWith(name: v, error: null);
  void setDob(DateTime d) => state = state.copyWith(dob: d, error: null);

  NumerologyInput? buildInput() {
    if (state.name.trim().isEmpty) {
      state = state.copyWith(error: 'Please enter a name');
      return null;
    }
    if (state.dob == null) {
      state = state.copyWith(error: 'Please select Date of Birth');
      return null;
    }
    return NumerologyInput(name: state.name.trim(), dob: state.dob!);
  }
}

final numerologyFormProvider =
StateNotifierProvider<NumerologyFormNotifier, NumerologyFormState>(
      (ref) => NumerologyFormNotifier(),
);
