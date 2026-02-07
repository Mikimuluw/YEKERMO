import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:yekermo/app/referral_provider.dart';
import 'package:yekermo/app/routes.dart';
import 'package:yekermo/features/referral/referral_share.dart';
import 'package:yekermo/shared/tokens/app_spacing.dart';
import 'package:yekermo/ui/app_list_tile.dart';
import 'package:yekermo/ui/app_scaffold.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final referral = ref.watch(referralProvider);
    final code = referral.code;
    return AppScaffold(
      title: 'Settings',
      body: ListView(
        padding: AppSpacing.pagePadding,
        children: [
          AppListTile(
            title: 'Preferences',
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(Routes.preferences),
          ),
          AppListTile(
            title: 'Invite',
            subtitle: code.isEmpty ? 'Invite code is not available.' : null,
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
