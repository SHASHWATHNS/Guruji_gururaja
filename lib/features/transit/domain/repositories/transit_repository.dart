import '../entities/transit_models.dart';

abstract class TransitRepository {
  /// Fetch transit data for a given local [date], [timezone], [lat], [lng].
  Future<TransitDay> getTransitForDay({
    required DateTime date,
    required String timezone,
    required double lat,
    required double lng,
  });
}
