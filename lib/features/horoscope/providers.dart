// lib/features/horoscope/providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../../core/config/app_config.dart';
import 'data/cache.dart';
import 'data/repository.dart';
import 'form/horoscope_form_screen.dart' show BirthData, birthDataProvider;
import 'tabs/summary/summary_service.dart' show AstroRequest;

// Repository (injectable)
final horoscopeRepoProvider = Provider<HoroscopeRepository>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: AppConfig.astroBaseUrl,
    connectTimeout: const Duration(seconds: 20),
    receiveTimeout: const Duration(seconds: 20),
    headers: {
      'Content-Type': 'application/json',
      'x-api-key': AppConfig.astroApiKey,
    },
  ));
  return HoroscopeRepository(dio: dio, cache: Cache());
});

/// SUMMARY: cached by AstroRequest
final summaryJsonProvider =
FutureProvider.autoDispose.family<Map<String, dynamic>, AstroRequest>((ref, req) async {
  final repo = ref.read(horoscopeRepoProvider);
  return repo.getSummary(req);
});

/// CHART: cached by BirthData
final chartJsonProvider =
FutureProvider.autoDispose.family<Map<String, dynamic>, BirthData>((ref, bd) async {
  final repo = ref.read(horoscopeRepoProvider);
  return repo.getCharts(bd);
});

/// DASHA: cached by BirthData
final dashaJsonProvider =
FutureProvider.autoDispose.family<Map<String, dynamic>, BirthData>((ref, bd) async {
  final repo = ref.read(horoscopeRepoProvider);
  return repo.getDasha(bd);
});
