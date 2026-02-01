import 'package:flutter/material.dart';
import 'package:yekermo/features/common/placeholder_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Favorites',
      subtitle: 'Save dishes and restaurants you love.',
    );
  }
}
