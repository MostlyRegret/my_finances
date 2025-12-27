DateTime addMonths(DateTime date, int monthsToAdd) {
  final y = date.year;
  final m = date.month + monthsToAdd;

  final newYear = y + ((m - 1) ~/ 12);
  final newMonth = ((m - 1) % 12) + 1;

  // Clamp day to last day of new month
  final lastDay = DateTime(newYear, newMonth + 1, 0).day;
  final newDay = date.day > lastDay ? lastDay : date.day;

  return DateTime(
    newYear,
    newMonth,
    newDay,
    date.hour,
    date.minute,
    date.second,
    date.millisecond,
    date.microsecond,
  );
}
