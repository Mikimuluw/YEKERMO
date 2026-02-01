import 'package:flutter/material.dart';
import 'package:yekermo/features/common/placeholder_screen.dart';

class RestaurantScreen extends StatelessWidget {
  const RestaurantScreen({super.key, required this.restaurantId});

  final String restaurantId;

  @override
  Widget build(BuildContext context) {
    return PlaceholderScreen(
      title: 'Restaurant',
      subtitle: 'Restaurant details for $restaurantId.',
    );
  }
}
