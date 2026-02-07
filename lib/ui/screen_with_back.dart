import 'package:flutter/material.dart';
import 'package:yekermo/shared/tokens/app_spacing.dart';
import 'package:yekermo/ui/app_bar_with_back.dart';
import 'package:yekermo/ui/app_scaffold.dart';

/// Screen wrapper that standardizes back button, title, safe area, padding, and scroll.
///
/// Use for any secondary screen (receipt, order tracking, detail, etc.). Body is
/// wrapped in [SafeArea] (top: false) and a scrollable [ListView] with
/// [AppSpacing.pagePadding]. Pass [children] so the list scrolls correctly.
class ScreenWithBack extends StatelessWidget {
  const ScreenWithBack({
    super.key,
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBarWithBack(title: title),
      body: SafeArea(
        top: false,
        child: ListView(padding: AppSpacing.pagePadding, children: children),
      ),
    );
  }
}
