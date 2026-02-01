import 'dart:developer' as developer;

class AppLog {
  const AppLog();

  void d(String message) => _log('DEBUG', message);
  void i(String message) => _log('INFO', message);
  void w(String message) => _log('WARN', message);
  void e(String message, [Object? error, StackTrace? stackTrace]) =>
      _log('ERROR', message, error: error, stackTrace: stackTrace);

  static void debug(String message) => _log('DEBUG', message);
  static void info(String message) => _log('INFO', message);
  static void warn(String message) => _log('WARN', message);
  static void error(String message, [Object? error, StackTrace? stackTrace]) =>
      _log('ERROR', message, error: error, stackTrace: stackTrace);

  static void _log(
    String level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    developer.log(
      message,
      name: 'Yekermo/$level',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
