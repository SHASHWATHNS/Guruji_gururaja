import '../entities/month_cell.dart';

class FetchMonthSummary {
  List<MonthCell> call(DateTime monthAnchor) {
    // Build a 6x7 grid (42 cells)
    final firstOfMonth = DateTime(monthAnchor.year, monthAnchor.month, 1);
    final startWeekday = firstOfMonth.weekday; // 1 Mon .. 7 Sun
    final start = firstOfMonth.subtract(Duration(days: startWeekday % 7));
    final today = DateTime.now();

    return List.generate(42, (i) {
      final d = DateTime(start.year, start.month, start.day + i);
      final inMonth = d.month == monthAnchor.month;
      final isToday = d.year == today.year && d.month == today.month && d.day == today.day;
      return MonthCell(date: d, inCurrentMonth: inMonth, isToday: isToday);
    });
  }
}
