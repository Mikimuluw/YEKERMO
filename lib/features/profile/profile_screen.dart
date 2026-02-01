import 'package:flutter/material.dart';
import 'package:yekermo/features/common/placeholder_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Profile',
      subtitle: 'Manage your account and preferences.',
    );
  }
}
