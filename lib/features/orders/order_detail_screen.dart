import 'package:flutter/material.dart';
import 'package:yekermo/features/common/placeholder_screen.dart';

class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    return PlaceholderScreen(
      title: 'Order details',
      subtitle: 'Order details for $orderId.',
    );
  }
}
