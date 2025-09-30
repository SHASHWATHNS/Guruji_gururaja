import '../../data/models/good_bad_times_model.dart';

class DayPanchanga {
  final DateTime date;
  final String sunrise;
  final String sunset;

  final String? tithiName;
  final String? nakshatraName;
  final String? yogaName;
  final String? karanaName;

  final GoodBadTimes goodBadTimes;

  final String? vedicWeekdayName;
  final String? rituName;
  final String? samvatName;
  final String? aayanam;

  DayPanchanga({
    required this.date,
    required this.sunrise,
    required this.sunset,
    required this.goodBadTimes,
    this.tithiName,
    this.nakshatraName,
    this.yogaName,
    this.karanaName,
    this.vedicWeekdayName,
    this.rituName,
    this.samvatName,
    this.aayanam,
  });
}
