import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'ui/home/home_screen.dart';

void main() {
  runApp(const AdvancedTreesApp());
}

class AdvancedTreesApp extends StatelessWidget {
  const AdvancedTreesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Árvores Avançadas',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const HomeScreen(),
    );
  }
}
