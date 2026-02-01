import 'package:flutter/material.dart';
import 'package:yekermo/shared/tokens/app_spacing.dart';

class AppChip extends StatelessWidget {
  const AppChip({super.key, required this.label, this.onPressed, this.icon});

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSpacing.tapTarget,
      child: Center(
        child: ActionChip(
          label: Text(label),
          onPressed: onPressed,
          avatar: icon == null ? null : Icon(icon, size: 18),
        ),
      ),
    );
  }
}
