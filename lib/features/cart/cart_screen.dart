import 'package:flutter/material.dart';
import 'package:yekermo/features/common/placeholder_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Cart',
      subtitle: 'Items you plan to checkout will appear here.',
    );
  }
}
