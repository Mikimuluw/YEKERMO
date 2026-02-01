import 'package:flutter/material.dart';
import 'package:yekermo/features/common/placeholder_screen.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Orders',
      subtitle: 'Your orders will appear here.',
    );
  }
}
