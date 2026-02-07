import 'package:yekermo/core/storage/welcome_storage.dart';

/// Fake for welcome gate. Default [seen] is true to skip the gate in most tests.
/// Use [seen: false] and then tap Continue to test the welcome flow (markSeen updates state).
class FakeWelcomeStorage implements WelcomeStorage {
  FakeWelcomeStorage({bool seen = true}) : _seen = seen;

  bool _seen;

  @override
  Future<bool> hasSeen() async => _seen;

  @override
  Future<void> markSeen() async {
    _seen = true;
  }
}
