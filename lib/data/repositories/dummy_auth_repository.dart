import 'package:yekermo/domain/auth_session.dart';
import 'package:yekermo/data/repositories/auth_repository.dart';

/// Dummy auth for dev: no real backend. Returns a stub session so app can run.
/// When [useRealBackend] is true, use [ApiAuthRepository] (or equivalent) instead.
class DummyAuthRepository implements AuthRepository {
  const DummyAuthRepository({this.stubSession});

  final AuthSession? stubSession;

  @override
  Future<AuthSession?> getSession() async => stubSession;

  @override
  Future<AuthSession> signIn({
    required String email,
    required String password,
  }) async {
    return stubSession ??
        const AuthSession(userId: 'dev-user-1', token: 'dummy-token');
  }

  @override
  Future<void> signOut() async {}
}
