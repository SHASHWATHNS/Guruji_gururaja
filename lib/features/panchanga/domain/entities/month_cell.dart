class MonthCell {
  final DateTime date;
  final bool inCurrentMonth;
  final bool isToday;

  const MonthCell({
    required this.date,
    required this.inCurrentMonth,
    required this.isToday,
  });
}
