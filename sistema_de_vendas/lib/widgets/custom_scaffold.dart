import 'package:flutter/material.dart';
import 'drawer_widget.dart';

class CustomScaffold extends StatelessWidget {
  final Widget body;
  final String title;
  final List<Widget>? actions;
  final bool showDrawer;

  const CustomScaffold({
    required this.body,
    this.title = 'GameStore',
    this.actions,
    this.showDrawer = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: actions,
      ),
      drawer: showDrawer ? DrawerWidget() : null,
      body: body,
    );
  }
}