import 'package:flutter/material.dart';
import 'package:yekermo/shared/tokens/app_radii.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.onTap,
  });

  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.br16,
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
