import 'package:flutter/material.dart';
import 'package:yekermo/ui/app_scaffold.dart';
import 'package:yekermo/ui/empty_state.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Favorites',
      body: const EmptyState(
        title: 'No favorites yet.',
        message: 'Save restaurants to see them here.',
        icon: Icons.favorite_border,
      ),
    );
  }
}
