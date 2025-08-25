import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/transit_repository_impl.dart';
import '../../domain/entities/transit_models.dart';
import '../../domain/repositories/transit_repository.dart';

// ---- CONFIG / DEFAULTS ----
const String _defaultTz = 'Asia/Kolkata';
const double _defaultLat = 11.6643;   // Example: Salem, TN (adjust if needed)
const double _defaultLng = 78.1460;

// Bind the repository (swap to your API impl later)
final transitRepositoryProvider = Provider<TransitRepository>((ref) {
  return TransitRepositoryMock();
});

// Selected date provider (UI can update it)
final transitSelectedDateProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

// Core Async data provider
final transitDayProvider = FutureProvider<TransitDay>((ref) async {
  final repo = ref.watch(transitRepositoryProvider);
  final date = ref.watch(transitSelectedDateProvider);
  return repo.getTransitForDay(
    date: date,
    timezone: _defaultTz,
    lat: _defaultLat,
    lng: _defaultLng,
  );
});
