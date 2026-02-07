enum Environment { dev, stage, prod }

/// Phase 12.1: One real environment (staging or prod-lite) required.
/// [Environment.stage] is the designated real environment; backend must be deployed and auth/orders/users/restaurants real.
class AppEnv {
  static Environment get current {
    const String raw = String.fromEnvironment('ENV', defaultValue: 'dev');
    switch (raw) {
      case 'prod':
        return Environment.prod;
      case 'stage':
        return Environment.stage;
      default:
        return Environment.dev;
    }
  }

  /// True when running against the one real backend (stage or prod-lite).
  static bool get isRealEnvironment =>
      current == Environment.stage || current == Environment.prod;

  static String get apiBaseUrl {
    switch (current) {
      case Environment.prod:
        return 'https://api.prod';
      case Environment.stage:
        return 'https://yekermo-production.up.railway.app';
      case Environment.dev:
        return 'https://dev.api.local';
    }
  }
}
