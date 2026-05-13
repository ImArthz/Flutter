import 'package:flutter/material.dart';
import 'homepage.dart';
import 'calc1_page.dart';
import 'calc2_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/homepage',
      routes: {
        '/homepage': (context) => HomePage(),
        '/calc1': (context) => Calc1Page(),
        '/calc2': (context) => Calcu(),
      },
    );
  }
}
