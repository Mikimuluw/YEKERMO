import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yekermo/core/time/clock.dart';

final clockProvider = Provider<Clock>((ref) => const SystemClock());
