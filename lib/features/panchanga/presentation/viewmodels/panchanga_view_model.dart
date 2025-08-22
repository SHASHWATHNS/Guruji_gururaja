import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/panchanga.dart';
import '../../domain/repositories/panchanga_repository.dart';
import '../../data/mock_panchanga_repository.dart';

class PanchangaState {
  final DateTime date;
  final bool loading;
  final PanchangaData? data;
  final String? error;

  const PanchangaState({
    required this.date,
    this.loading = false,
    this.data,
    this.error,
  });

  PanchangaState copyWith({
    DateTime? date,
    bool? loading,
    PanchangaData? data,
    String? error,
  }) =>
      PanchangaState(
        date: date ?? this.date,
        loading: loading ?? this.loading,
        data: data ?? this.data,
        error: error,
      );
}

class PanchangaViewModel extends StateNotifier<PanchangaState> {
  final PanchangaRepository _repo;

  PanchangaViewModel(this._repo)
      : super(PanchangaState(date: DateTime.now())) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(loading: true, error: null);
    try {
      final res = await _repo.getPanchanga(date: state.date);
      state = state.copyWith(loading: false, data: res);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> previousDay() async {
    state = state.copyWith(date: state.date.subtract(const Duration(days: 1)));
    await load();
  }

  Future<void> nextDay() async {
    state = state.copyWith(date: state.date.add(const Duration(days: 1)));
    await load();
  }

  Future<void> setDate(DateTime date) async {
    state = state.copyWith(date: date);
    await load();
  }
}

final panchangaProvider =
StateNotifierProvider<PanchangaViewModel, PanchangaState>((ref) {
  // Swap with real implementation when available
  return PanchangaViewModel(const MockPanchangaRepository());
});
