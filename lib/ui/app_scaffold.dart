import 'package:flutter/material.dart';
import 'package:yekermo/ui/app_appbar.dart';

/// Screen-level scaffold. Takes content; layout is caller's (e.g. wrap body in padded content).
///
/// Use [title] for a standard app bar, or [appBar] for custom content.
/// [body] is wrapped in [SafeArea] (top: false so app bar spans full height).
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    this.title,
    this.actions,
    this.appBar,
    required this.body,
  });

  /// Shorthand: app bar with [title] and [actions]. Ignored if [appBar] is set.
  final String? title;
  final List<Widget>? actions;

  /// Custom app bar. If set, [title] and [actions] are ignored.
  final PreferredSizeWidget? appBar;

  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar ?? (title != null ? AppAppBar(title: title!, actions: actions) : null),
      body: SafeArea(top: false, child: body),
    );
  }
}
