import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yekermo/app/user_preferences_provider.dart';

class PreferencesScreen extends ConsumerWidget {
  const PreferencesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(userPreferencesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Preferences')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Prefer pickup'),
            value: prefs.pickupPreferred,
            onChanged: (v) => ref
                .read(userPreferencesProvider.notifier)
                .update(prefs.copyWith(pickupPreferred: v)),
          ),
          SwitchListTile(
            title: const Text('Fasting-friendly meals'),
            value: prefs.fastingFriendly,
            onChanged: (v) => ref
                .read(userPreferencesProvider.notifier)
                .update(prefs.copyWith(fastingFriendly: v)),
          ),
          SwitchListTile(
            title: const Text('Vegetarian options'),
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
