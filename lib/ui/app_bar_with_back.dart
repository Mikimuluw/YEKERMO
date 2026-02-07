import 'package:flutter/material.dart';

/// Standard app bar with back button and title. Use for every screen that needs back (Receipt, Order tracking, Cart, Checkout, etc.).
///
/// Same layout as [ScreenWithBack] top area; keeps back behavior and title style consistent.
class AppBarWithBack extends StatelessWidget implements PreferredSizeWidget {
  const AppBarWithBack({super.key, required this.title});

  final String title;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
        tooltip: 'Back',
      ),
      title: Text(title),
    );
  }
}
