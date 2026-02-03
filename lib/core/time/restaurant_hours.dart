class _TimeRange {
  const _TimeRange(this.startMinutes, this.endMinutes);

  final int startMinutes;
  final int endMinutes;

  bool get spansMidnight => endMinutes < startMinutes;
}

bool isOpenNow(Map<int, String> hoursByWeekday, DateTime now) {
  final int minutes = now.hour * 60 + now.minute;
  final int weekday = now.weekday;

  final _TimeRange? todayRange = _parseRange(hoursByWeekday[weekday]);
  if (todayRange != null) {
    if (!todayRange.spansMidnight) {
      if (minutes >= todayRange.startMinutes &&
          minutes < todayRange.endMinutes) {
        return true;
      }
    } else {
      if (minutes >= todayRange.startMinutes) return true;
    }
  }

  final int previousDay = weekday == DateTime.monday
      ? DateTime.sunday
      : weekday - 1;
  final _TimeRange? previousRange = _parseRange(
    hoursByWeekday[previousDay],
  );
  if (previousRange != null && previousRange.spansMidnight) {
    return minutes < previousRange.endMinutes;
  }
  return false;
}

_TimeRange? _parseRange(String? value) {
  if (value == null) return null;
  final String normalized = value.replaceAll('–', '-').replaceAll('—', '-');
  final List<String> parts = normalized.split('-');
  if (parts.length != 2) return null;
  final int? start = _parseMinutes(parts[0].trim());
  final int? end = _parseMinutes(parts[1].trim());
  if (start == null || end == null) return null;
  return _TimeRange(start, end);
}

int? _parseMinutes(String value) {
  final RegExp match = RegExp(r'^(\d{1,2}):(\d{2})$');
  final RegExpMatch? found = match.firstMatch(value);
  if (found == null) return null;
  final int hours = int.parse(found.group(1)!);
  final int minutes = int.parse(found.group(2)!);
  if (hours < 0 || hours > 23) return null;
  if (minutes < 0 || minutes > 59) return null;
  return hours * 60 + minutes;
}
