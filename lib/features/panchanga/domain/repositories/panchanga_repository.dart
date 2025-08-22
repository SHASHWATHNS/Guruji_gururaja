import '../entities/panchanga.dart';

abstract class PanchangaRepository {
  Future<PanchangaData> getPanchanga({
    required DateTime date,
    String place = 'Chennai, India',
    int tzHour = 5,
    int tzMinute = 30,
  });
}
