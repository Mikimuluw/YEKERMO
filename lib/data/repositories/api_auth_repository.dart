import 'package:yekermo/core/storage/auth_storage.dart';
import 'package:yekermo/core/transport/transport_client.dart';
import 'package:yekermo/domain/auth_session.dart';
import 'package:yekermo/data/repositories/auth_repository.dart';

/// API auth for Phase 12.1. Calls backend /auth/sign-in and persists session.
class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository({
    required this.transportClient,
    required this.authStorage,
  });

  final TransportClient transportClient;
  final AuthStorage authStorage;

  @override
  Future<AuthSession?> getSession() async {
    return authStorage.getSession();
  }

  @override
  Future<AuthSession> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await transportClient.request<Map<String, dynamic>>(
        TransportRequest(
          method: 'POST',
          url: Uri(path: '/auth/sign-in'),
          body: {'email': email, 'password': password},
          timeout: const Duration(seconds: 10),
        ),
      );

      final data = response.data;
      final session = AuthSession(
        userId: data['userId'] as String,
        token: data['token'] as String,
      );

      await authStorage.saveSession(session);
      return session;
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  @override
  Future<void> signOut() async {
    // Optionally call backend to revoke token
    // await transportClient.request(TransportRequest(method: 'POST', url: Uri(path: '/auth/sign-out')));
    await authStorage.clearSession();
  }
}
