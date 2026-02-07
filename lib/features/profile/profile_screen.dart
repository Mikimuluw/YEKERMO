import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yekermo/app/routes.dart';
import 'package:yekermo/shared/extensions/context_extensions.dart';
import 'package:yekermo/shared/tokens/app_spacing.dart';
import 'package:yekermo/ui/app_list_tile.dart';
import 'package:yekermo/ui/app_scaffold.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Profile',
      body: ListView(
        padding: AppSpacing.pagePadding,
        children: [
          Text(
            'Account and settings for this device.',
            style: context.text.bodyMedium?.copyWith(
              color: context.textMuted,
            ),
          ),
          AppSpacing.vMd,
          AppListTile(
            title: 'Settings',
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(Routes.settings),
          ),
        ],
      ),
    );
  }
}
