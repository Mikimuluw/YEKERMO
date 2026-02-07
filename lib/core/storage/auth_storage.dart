import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:yekermo/domain/auth_session.dart';

/// Secure storage for auth session. Uses flutter_secure_storage for token persistence.
abstract class AuthStorage {
  Future<AuthSession?> getSession();
  Future<void> saveSession(AuthSession session);
  Future<void> clearSession();
}

/// Secure auth storage using flutter_secure_storage.
class SecureAuthStorage implements AuthStorage {
  SecureAuthStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const String _keyUserId = 'auth_user_id';
  static const String _keyToken = 'auth_token';

  @override
  Future<AuthSession?> getSession() async {
    final String? userId = await _storage.read(key: _keyUserId);
    final String? token = await _storage.read(key: _keyToken);

    if (userId == null || token == null) {
      return null;
    }

    return AuthSession(userId: userId, token: token);
  }

  @override
  Future<void> saveSession(AuthSession session) async {
    await _storage.write(key: _keyUserId, value: session.userId);
    await _storage.write(key: _keyToken, value: session.token);
  }

  @override
  Future<void> clearSession() async {
    await _storage.delete(key: _keyUserId);
    await _storage.delete(key: _keyToken);
  }
}
