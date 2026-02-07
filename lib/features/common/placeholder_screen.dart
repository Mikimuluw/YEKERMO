import 'package:flutter/material.dart';
import 'package:yekermo/ui/app_scaffold.dart';
import 'package:yekermo/ui/empty_state.dart';

/// Placeholder for screens not yet implemented. Uses [EmptyState].
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: title,
      body: EmptyState(title: subtitle ?? 'Not available.'),
    );
  }
}
