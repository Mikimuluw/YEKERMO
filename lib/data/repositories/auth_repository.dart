import 'package:yekermo/domain/auth_session.dart';

/// Minimal auth for Phase 12.1. Backend issues session; app sends token on requests.
abstract class AuthRepository {
  /// Current session if signed in; null otherwise.
  Future<AuthSession?> getSession();

  /// Sign in with credentials; returns session or throws.
  Future<AuthSession> signIn({required String email, required String password});

  /// Clear session (and optionally revoke on backend).
  Future<void> signOut();
}
