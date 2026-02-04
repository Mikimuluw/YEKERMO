import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:yekermo/app/referral_provider.dart';
import 'package:yekermo/app/routes.dart';
import 'package:yekermo/features/referral/referral_share.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final referral = ref.watch(referralProvider);
    final code = referral.code;
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Preferences'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(Routes.preferences),
          ),
          ListTile(
            title: const Text('Invite'),
            trailing: const Icon(Icons.chevron_right),
            onTap: code.isEmpty
                ? null
                : () async {
                    await Share.share(referralShareMessage(code));
                    ref.read(referralProvider.notifier).incrementSent();
                  },
          ),
        ],
      ),
    );
  }
}
