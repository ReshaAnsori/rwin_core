import 'package:intl/intl.dart';

/// ISO 8601 / common date format constants.
class RwinDateFormat {
  RwinDateFormat._();

  static const String date = 'yyyy-MM-dd';
  static const String dateTime = 'yyyy-MM-dd HH:mm:ss';
  static const String displayDate = 'dd MMM yyyy';
  static const String displayDateTime = 'dd MMM yyyy HH:mm';
  static const String time = 'HH:mm';
  static const String timeFull = 'HH:mm:ss';
  static const String monthYear = 'MMM yyyy';
}

extension DateTimeEx on DateTime? {
  bool get hasValue => this != null;

  /// Parses an ISO 8601 string or time-only string (`HH:mm` / `HH:mm:ss`).
  /// Returns `null` on parse failure.
  static DateTime? tryParseSafe(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final v = raw.trim();

    // time-only: HH:mm or HH:mm:ss → anchor to today
    final timeOnly = RegExp(r'^\d{1,2}:\d{2}(:\d{2})?$');
    if (timeOnly.hasMatch(v)) {
      final parts = v.split(':');
      final h = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      final s = parts.length > 2 ? int.tryParse(parts[2]) : 0;
      if (h == null || m == null) return null;
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day, h, m, s ?? 0);
    }

    try {
      return DateTime.parse(v);
    } catch (_) {
      return null;
    }
  }

  DateTime? getStartOfDay() {
    if (!hasValue) return null;
    return DateTime(this!.year, this!.month, this!.day);
  }

  bool isAfterOrEqualTo(DateTime? other) {
    if (!hasValue || other == null) return false;
    return this!.isAtSameMomentAs(other) || this!.isAfter(other);
  }

  bool isBeforeOrEqualTo(DateTime? other) {
    if (!hasValue || other == null) return false;
    return this!.isAtSameMomentAs(other) || this!.isBefore(other);
  }

  bool isEqualDate(DateTime? other) {
    if (!hasValue || other == null) return false;
    return this!.year == other.year &&
        this!.month == other.month &&
        this!.day == other.day;
  }

  bool isEqualDateTime(DateTime? other) {
    if (!hasValue || other == null) return false;
    return this!.isAtSameMomentAs(other);
  }

  bool isBetween(DateTime? from, DateTime? to) {
    if (!hasValue || from == null || to == null) return false;
    return isAfterOrEqualTo(from) && isBeforeOrEqualTo(to);
  }

  /// Human-readable duration between this and [end], e.g. `"2h 30m"`.
  String timeDiff({required DateTime? end, String fallback = ''}) {
    if (!hasValue || end == null) return fallback;
    final d = end.difference(this!).abs();
    return '${d.inHours}h ${d.inMinutes.remainder(60)}m';
  }

  int? dayDiff({required DateTime? end}) {
    if (!hasValue || end == null) return null;
    return this!.difference(end).inDays;
  }

  /// Number of calendar days from this to [end] (inclusive).
  int dayCount({required DateTime? end}) {
    if (!hasValue || end == null) return 0;
    return this!.difference(end).inDays.abs() + 1;
  }

  /// Format using [pattern] (default: `dd MMM yyyy`). Returns [fallback] when null.
  String format({
    String pattern = RwinDateFormat.displayDate,
    String locale = 'en',
    String fallback = '',
  }) {
    if (!hasValue) return fallback;
    return DateFormat(pattern, locale).format(this!);
  }
}
