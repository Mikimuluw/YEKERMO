import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yekermo/app/di.dart';
import 'package:yekermo/app/providers.dart';
import 'package:yekermo/app/routes.dart';
import 'package:yekermo/data/repositories/me_repository.dart';
import 'package:yekermo/shared/extensions/context_extensions.dart';
import 'package:yekermo/shared/tokens/app_spacing.dart';
import 'package:yekermo/ui/app_card.dart';
import 'package:yekermo/ui/app_list_tile.dart';
import 'package:yekermo/ui/app_scaffold.dart';
import 'package:yekermo/ui/app_section_header.dart';

/// Account screen (shell tab). When useRealBackend, shows name/email from GET /me.
class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(appConfigProvider);
    final meAsync = config.useRealBackend ? ref.watch(meProfileProvider) : null;
    final String name;
    final String email;
    switch (meAsync?.value) {
      case MeProfile(customer: final c, email: final e):
        name = c.name;
        email = e.isNotEmpty ? e : 'Signed in';
      default:
        name = _stubName;
        email = _stubEmail;
    }
    return AppScaffold(
      title: 'Account',
      body: ListView(
        padding: AppSpacing.pagePadding,
        children: [
          _ProfileRow(name: name, email: email),
          AppSpacing.vLg,
          const AppSectionHeader(title: 'Account settings'),
          AppSpacing.vSm,
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppListTile(
                  title: 'Profile information',
                  trailing: Icon(
                    Icons.chevron_right,
                    color: context.textTertiary,
                  ),
                  onTap: () {},
                ),
                AppListTile(
                  title: 'Settings',
                  trailing: Icon(
                    Icons.chevron_right,
                    color: context.textTertiary,
                  ),
                  onTap: () => context.push(Routes.settings),
                ),
                if (config.useRealBackend)
                  AppListTile(
                    title: 'Sign out',
                    trailing: Icon(
                      Icons.logout,
                      color: context.textTertiary,
                    ),
                    onTap: () => _signOut(context, ref),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    await ref.read(authRepositoryProvider).signOut();
    ref.invalidate(meProfileProvider);
    ref.invalidate(addressControllerProvider);
    ref.invalidate(homeControllerProvider);
    ref.invalidate(ordersControllerProvider);
    if (context.mounted) context.go(Routes.signIn);
  }
}

// --- Stub data when not using real backend ---

const String _stubName = 'Michael Chen';
const String _stubEmail = 'michael.chen@email.com';

// --- Helper widgets (same file) ---

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({required this.name, required this.email});

  final String name;
  final String email;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: context.colors.surfaceContainerHighest,
          child: Icon(
            Icons.person_outline,
            size: 32,
            color: context.textTertiary,
          ),
        ),
        AppSpacing.hMd,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(name, style: context.text.titleMedium),
              AppSpacing.vXs,
              Text(
                email,
                style: context.text.bodyMedium?.copyWith(
                  color: context.textMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
