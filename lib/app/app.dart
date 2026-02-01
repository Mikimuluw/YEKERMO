import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yekermo/app/router.dart';
import 'package:yekermo/app/theme.dart';

class YekermoApp extends StatelessWidget {
  const YekermoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final GoRouter router = appRouter;

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Yekermo',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
