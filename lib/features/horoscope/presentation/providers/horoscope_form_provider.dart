import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/birth_input.dart';

class PlacePick {
  final String label;
  final double lat;
  final double lng;
  final String tzid;
  const PlacePick({required this.label, required this.lat, required this.lng, required this.tzid});
}

class HoroscopeFormState {
  final String name;
  final DateTime? dob;       // date only
  final String tob24h;       // "HH:mm"
  final bool unknownTime;

  final PlacePick? place;    // set from place picker
  final String? error;

  const HoroscopeFormState({
    this.name = '',
    this.dob,
    this.tob24h = '',
    this.unknownTime = false,
    this.place,
    this.error,
  });

  HoroscopeFormState copyWith({
    String? name,
    DateTime? dob,
    String? tob24h,
    bool? unknownTime,
    PlacePick? place,
    String? error, bool clearError = false,
  }) {
    return HoroscopeFormState(
      name: name ?? this.name,
      dob: dob ?? this.dob,
      tob24h: tob24h ?? this.tob24h,
      unknownTime: unknownTime ?? this.unknownTime,
      place: place ?? this.place,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class HoroscopeFormNotifier extends StateNotifier<HoroscopeFormState> {
  HoroscopeFormNotifier(): super(const HoroscopeFormState());

  void setName(String v) => state = state.copyWith(name: v, clearError: true);
  void setDob(DateTime v) => state = state.copyWith(dob: v, clearError: true);
  void setTob(String v) => state = state.copyWith(tob24h: v, clearError: true);
  void toggleUnknown(bool v) => state = state.copyWith(unknownTime: v, clearError: true);
  void setPlace(PlacePick p) => state = state.copyWith(place: p, clearError: true);

  String? _validate() {
    if (state.name.trim().isEmpty) return 'Enter name';
    if (state.dob == null) return 'Select date of birth';
    if (!state.unknownTime && state.tob24h.trim().isEmpty) return 'Enter time of birth (24h)';
    if (state.place == null) return 'Select state & district';
    return null;
  }

  BirthInput? buildInput() {
    final err = _validate();
    if (err != null) {
      state = state.copyWith(error: err);
      return null;
    }
    final p = state.place!;
    return BirthInput(
      name: state.name.trim(),
      dobLocal: DateTime(state.dob!.year, state.dob!.month, state.dob!.day),
      tob24h: state.unknownTime ? null : state.tob24h,
      unknownTime: state.unknownTime,
      placeLabel: p.label,
      lat: p.lat,
      lng: p.lng,
      tzid: p.tzid,
    );
  }
}

final horoscopeFormProvider =
StateNotifierProvider<HoroscopeFormNotifier, HoroscopeFormState>(
      (ref) => HoroscopeFormNotifier(),
);
