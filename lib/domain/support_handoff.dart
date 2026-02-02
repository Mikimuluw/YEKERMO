import 'package:yekermo/domain/support.dart';

abstract class SupportHandoff {
  Future<void> submit(SupportRequestDraft draft);
}
