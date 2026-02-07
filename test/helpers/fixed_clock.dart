import 'package:yekermo/core/time/clock.dart';

class FixedClock extends Clock {
  final DateTime value;
  const FixedClock(this.value);
  @override
  DateTime now() => value;
}
