import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/static/indian_place.dart';

class PlacePickerState {
  final String? state;
  final String? district;
  final List<IndianPlace> all;

  const PlacePickerState({
    this.state,
    this.district,
    this.all = const [],
  });

  PlacePickerState copyWith({
    String? state,
    String? district,
    List<IndianPlace>? all,
  }) {
    return PlacePickerState(
      state: state ?? this.state,
      district: district ?? this.district,
      all: all ?? this.all,
    );
  }
}

class PlacePickerNotifier extends StateNotifier<PlacePickerState> {
  PlacePickerNotifier() : super(const PlacePickerState()) {
    // Load the offline demo list (swap with full JSON later)
    state = state.copyWith(all: indianPlaces);
  }

  void selectState(String s) => state = state.copyWith(state: s, district: null);

  void selectDistrict(String d) => state = state.copyWith(district: d);

  IndianPlace? get selected {
    if (state.state == null || state.district == null) return null;
    try {
      return state.all.firstWhere(
            (p) => p.state == state.state && p.district == state.district,
      );
    } catch (_) {
      return null;
    }
  }

  List<String> get states =>
      state.all.map((e) => e.state).toSet().toList()..sort();

  List<String> districtsOf(String? ofState) {
    if (ofState == null) return const [];
    final list = state.all.where((e) => e.state == ofState).map((e) => e.district).toSet().toList()
      ..sort();
    return list;
  }
}

final placePickerProvider =
StateNotifierProvider<PlacePickerNotifier, PlacePickerState>((ref) {
  return PlacePickerNotifier();
});
