import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static String formatDate(DateTime dt) {
    final bogotaTime = dt.toUtc().subtract(const Duration(hours: 5));
    return DateFormat('dd/MM/yyyy').format(bogotaTime);
  }

  static String formatDateTime(DateTime dt) {
    final bogotaTime = dt.toUtc().subtract(const Duration(hours: 5));
    return DateFormat('dd/MM/yyyy HH:mm').format(bogotaTime);
  }

  static String formatTime(DateTime dt) {
    final bogotaTime = dt.toUtc().subtract(const Duration(hours: 5));
    return DateFormat('HH:mm').format(bogotaTime);
  }

  static DateTime todayBogota() {
    return DateTime.now().toUtc().subtract(const Duration(hours: 5));
  }
}
