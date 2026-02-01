import 'package:flutter/material.dart';
import 'package:yekermo/features/common/placeholder_screen.dart';

class AddressManagerScreen extends StatelessWidget {
  const AddressManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Address Manager',
      subtitle: 'Manage and store delivery addresses.',
    );
  }
}
