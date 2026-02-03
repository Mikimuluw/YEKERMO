import 'package:flutter_test/flutter_test.dart';
import 'package:yekermo/core/time/restaurant_hours.dart';

void main() {
  test('isOpenNow respects open/close boundaries', () {
    const Map<int, String> hours = {
      1: '11:00-21:30',
      2: '11:00-21:30',
      3: '11:00-21:30',
      4: '11:00-21:30',
      5: '11:00-21:30',
      6: '11:00-21:30',
      7: '11:00-21:30',
    };

    final DateTime beforeOpen = DateTime(2026, 2, 2, 10, 59); // Monday
    final DateTime atOpen = DateTime(2026, 2, 2, 11, 0);
    final DateTime beforeClose = DateTime(2026, 2, 2, 21, 29);
    final DateTime atClose = DateTime(2026, 2, 2, 21, 30);

    expect(isOpenNow(hours, beforeOpen), isFalse);
    expect(isOpenNow(hours, atOpen), isTrue);
    expect(isOpenNow(hours, beforeClose), isTrue);
    expect(isOpenNow(hours, atClose), isFalse);
  });

  test('isOpenNow handles hours that span midnight', () {
    const Map<int, String> hours = {
      1: '10:00-02:00', // Monday
      2: '10:00-02:00',
      3: '10:00-02:00',
      4: '10:00-02:00',
      5: '10:00-02:00',
      6: '10:00-02:00',
      7: '10:00-02:00',
    };

    final DateTime mondayLate = DateTime(2026, 2, 2, 23, 45);
    final DateTime tuesdayEarly = DateTime(2026, 2, 3, 1, 30);
    final DateTime tuesdayAfterClose = DateTime(2026, 2, 3, 2, 0);

    expect(isOpenNow(hours, mondayLate), isTrue);
    expect(isOpenNow(hours, tuesdayEarly), isTrue);
    expect(isOpenNow(hours, tuesdayAfterClose), isFalse);
  });
}
