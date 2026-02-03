import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yekermo/app/routes.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Preferences'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(Routes.preferences),
          ),
        ],
      ),
    );
  }
}
