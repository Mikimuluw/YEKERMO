import 'package:flutter/material.dart';
import 'package:yekermo/features/common/placeholder_screen.dart';

class MenuItemScreen extends StatelessWidget {
  const MenuItemScreen({super.key, required this.itemId});

  final String itemId;

  @override
  Widget build(BuildContext context) {
    return PlaceholderScreen(
      title: 'Meal',
      subtitle: 'Meal details for $itemId.',
    );
  }
}
