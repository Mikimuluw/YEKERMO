import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yekermo/app/app.dart';
import 'package:yekermo/observability/app_log.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    AppLog.error('Flutter framework error', details.exception, details.stack);
  };

  WidgetsBinding.instance.platformDispatcher.onError = (error, stackTrace) {
    AppLog.error('Uncaught platform error', error, stackTrace);
    return true;
  };

  runApp(
    const ProviderScope(
      child: YekermoApp(),
    ),
  );
}
