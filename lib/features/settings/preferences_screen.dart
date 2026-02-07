import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yekermo/app/user_preferences_provider.dart';
import 'package:yekermo/shared/extensions/context_extensions.dart';
import 'package:yekermo/shared/tokens/app_spacing.dart';
import 'package:yekermo/ui/app_scaffold.dart';

class PreferencesScreen extends ConsumerWidget {
  const PreferencesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(userPreferencesProvider);

    return AppScaffold(
      title: 'Preferences',
      body: ListView(
        padding: AppSpacing.pagePadding,
        children: [
          SwitchListTile(
            title: Text('Prefer pickup', style: context.text.bodyLarge),
            value: prefs.pickupPreferred,
            onChanged: (v) => ref
                .read(userPreferencesProvider.notifier)
                .update(prefs.copyWith(pickupPreferred: v)),
          ),
          SwitchListTile(
            title: Text('Fasting-friendly meals', style: context.text.bodyLarge),
            value: prefs.fastingFriendly,
            onChanged: (v) => ref
                .read(userPreferencesProvider.notifier)
                .update(prefs.copyWith(fastingFriendly: v)),
          ),
          SwitchListTile(
            title: Text('Vegetarian options', style: context.text.bodyLarge),
            value: prefs.vegetarianBias,
            onChanged: (v) => ref
                .read(userPreferencesProvider.notifier)
                .update(prefs.copyWith(vegetarianBias: v)),
          ),
        ],
      ),
    );
  }
}
