import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../horoscope/data/datasources/remote/horoscope_api_service.dart';
import '../../../horoscope/data/repositories/horoscope_repository_impl.dart';
import '../../../horoscope/domain/entities/birth_summary.dart';
import '../../domain/entities/birth_input.dart';

sealed class JSummaryState { const JSummaryState(); }
class JIdle extends JSummaryState { const JIdle(); }
class JLoading extends JSummaryState { const JLoading(); }
class JReady extends JSummaryState {
  final BirthSummary summary;
  const JReady(this.summary);
}
class JError extends JSummaryState {
  final String message; const JError(this.message);
}

final _apiProvider = Provider((ref) => HoroscopeApiService());
final _repoProvider = Provider((ref) => HoroscopeRepositoryImpl(ref.read(_apiProvider)));

final jSummaryProvider =
StateNotifierProvider<JSummaryNotifier, JSummaryState>((ref) {
  return JSummaryNotifier(ref.read(_repoProvider));
});

class JSummaryNotifier extends StateNotifier<JSummaryState> {
  final HoroscopeRepositoryImpl repo;
  JSummaryNotifier(this.repo) : super(const JIdle());

  Future<void> load(BirthInput input) async {
    state = const JLoading();
    try {
      final s = await repo.buildBirthSummary(
        name: input.name,
        dobLocal: input.dobLocal,
        tob24h: input.tob24h,
        unknownTime: input.unknownTime,
        placeLabel: input.placeLabel,
        lat: input.lat, lng: input.lng, tzid: input.tzid,
      );
      state = JReady(s);
    } catch (e) {
      state = JError(e.toString());
    }
  }
}
