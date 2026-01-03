import 'package:intl/intl.dart';

class DateUtils {
  // Format date to string (YYYY-MM-DD)
  static String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  // Format date for display (DD MMM YYYY)
  static String formatDisplayDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  // Format date with time
  static String formatDateTime(DateTime date) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(date);
  }

  // Parse string to date
  static DateTime parseDate(String dateStr) {
    return DateTime.parse(dateStr);
  }

  // Get today's date string
  static String getToday() {
    return formatDate(DateTime.now());
  }

  // Get first day of current month
  static String getFirstDayOfMonth() {
    final now = DateTime.now();
    return formatDate(DateTime(now.year, now.month, 1));
  }

  // Get last day of current month
  static String getLastDayOfMonth() {
    final now = DateTime.now();
    return formatDate(DateTime(now.year, now.month + 1, 0));
  }

  // Get first day of a specific month
  static String getFirstDayOfSpecificMonth(int year, int month) {
    return formatDate(DateTime(year, month, 1));
  }

  // Get last day of a specific month
  static String getLastDayOfSpecificMonth(int year, int month) {
    return formatDate(DateTime(year, month + 1, 0));
  }

  // Get date range for current week
  static Map<String, String> getCurrentWeekRange() {
    final now = DateTime.now();
    final firstDayOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final lastDayOfWeek = firstDayOfWeek.add(const Duration(days: 6));

    return {
      'start': formatDate(firstDayOfWeek),
      'end': formatDate(lastDayOfWeek),
    };
  }

  // Get date range for current month
  static Map<String, String> getCurrentMonthRange() {
    return {'start': getFirstDayOfMonth(), 'end': getLastDayOfMonth()};
  }

  // Check if date is today
  static bool isToday(String dateStr) {
    final date = parseDate(dateStr);
    final today = DateTime.now();
    return date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
  }

  // Get month name
  static String getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  // Get days between two dates
  static int getDaysBetween(String startDate, String endDate) {
    final start = parseDate(startDate);
    final end = parseDate(endDate);
    return end.difference(start).inDays + 1;
  }
}
