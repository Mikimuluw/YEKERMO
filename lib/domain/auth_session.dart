/// Minimal auth session for Phase 12.1 backend foundation.
/// Backend issues token; app sends it as Authorization on API requests.
class AuthSession {
  const AuthSession({
    required this.userId,
    required this.token,
  });

  final String userId;
  final String token;
}
