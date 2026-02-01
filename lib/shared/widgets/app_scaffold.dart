import 'package:flutter/material.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({super.key, this.title, this.actions, required this.body});

  final String? title;
  final List<Widget>? actions;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: title == null
          ? null
          : AppBar(title: Text(title!), actions: actions),
      body: SafeArea(top: false, child: body),
    );
  }
}
