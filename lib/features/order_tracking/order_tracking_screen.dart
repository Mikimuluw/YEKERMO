import 'package:flutter/material.dart';
import 'package:yekermo/features/common/placeholder_screen.dart';

class OrderTrackingScreen extends StatelessWidget {
  const OrderTrackingScreen({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    return PlaceholderScreen(
      title: 'Order Tracking',
      subtitle: 'Tracking details for $orderId.',
    );
  }
}
