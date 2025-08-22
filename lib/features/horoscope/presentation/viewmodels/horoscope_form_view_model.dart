import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../horoscope/domain/entities/horoscope_form.dart';

class HoroscopeFormState {
  final HoroscopeForm form;
  final bool submitting;
  final String? error;

  const HoroscopeFormState({
    required this.form,
    this.submitting = false,
    this.error,
  });

  HoroscopeFormState copyWith({
    HoroscopeForm? form,
    bool? submitting,
    String? error,
  }) =>
      HoroscopeFormState(
        form: form ?? this.form,
        submitting: submitting ?? this.submitting,
        error: error,
      );
}

class HoroscopeFormViewModel extends StateNotifier<HoroscopeFormState> {
  HoroscopeFormViewModel() : super(HoroscopeFormState(form: const HoroscopeForm()));

  void setName(String v) => state = state.copyWith(form: state.form.copyWith(name: v));

  void setDOB({int? d, int? m, int? y}) => state = state.copyWith(
    form: state.form.copyWith(
      day: d ?? state.form.day,
      month: m ?? state.form.month,
      year: y ?? state.form.year,
    ),
  );

  void setTOB({int? h, int? min, int? s}) => state = state.copyWith(
    form: state.form.copyWith(
      hour: h ?? state.form.hour,
      minute: min ?? state.form.minute,
      second: s ?? state.form.second,
    ),
  );

  void setPlace(String v) => state = state.copyWith(form: state.form.copyWith(place: v));

  void setGender(Gender g) => state = state.copyWith(form: state.form.copyWith(gender: g));

  void setLongitude({int? deg, int? min, String? dir}) => state = state.copyWith(
    form: state.form.copyWith(
      lonDeg: deg ?? state.form.lonDeg,
      lonMin: min ?? state.form.lonMin,
      lonDir: dir ?? state.form.lonDir,
    ),
  );

  void setLatitude({int? deg, int? min, String? dir}) => state = state.copyWith(
    form: state.form.copyWith(
      latDeg: deg ?? state.form.latDeg,
      latMin: min ?? state.form.latMin,
      latDir: dir ?? state.form.latDir,
    ),
  );

  void setTimeZone(int hour, int minute) =>
      state = state.copyWith(form: state.form.copyWith(tzHour: hour, tzMinute: minute));

  void toggleSave(bool v) => state = state.copyWith(form: state.form.copyWith(saveInPhone: v));

  void clear() => state = HoroscopeFormState(form: const HoroscopeForm());

  Future<void> submit() async {
    // Clear any past error
    state = state.copyWith(error: null);

    if (!state.form.isValidBasic) {
      state = state.copyWith(error: 'Please complete all required fields.');
      return;
    }
    state = state.copyWith(submitting: true, error: null);
    await Future<void>.delayed(const Duration(milliseconds: 600)); // mock work
    // TODO: call usecase/repository
    state = state.copyWith(submitting: false);
  }
}

final horoscopeFormProvider =
StateNotifierProvider<HoroscopeFormViewModel, HoroscopeFormState>(
        (ref) => HoroscopeFormViewModel());
