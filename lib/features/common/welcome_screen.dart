import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yekermo/app/providers.dart';
import 'package:yekermo/app/routes.dart';
import 'package:yekermo/shared/extensions/context_extensions.dart';
import 'package:yekermo/shared/tokens/app_spacing.dart';
import 'package:yekermo/ui/app_button.dart';
import 'package:yekermo/ui/app_scaffold.dart';

/// Single entry gate (Phase 13.0). No auth, no permissions, no slides.
class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  static const String appName = 'Yekermo';
  static const String valueCopy =
      'Order pickup or delivery from Calgary Ethiopian restaurants.';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme textTheme = context.text;

    return AppScaffold(
      body: Padding(
        padding: AppSpacing.pagePadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              appName,
              style: textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            AppSpacing.vMd,
            Text(
              valueCopy,
              style: textTheme.bodyLarge?.copyWith(
                color: context.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
            AppSpacing.vXl,
            AppButton(
              label: 'Continue',
              onPressed: () => _onContinue(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onContinue(BuildContext context, WidgetRef ref) async {
    await ref.read(welcomeStorageProvider).markSeen();
    if (context.mounted) context.go(Routes.home);
  }
}
