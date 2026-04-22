import 'package:flutter/material.dart';
import 'tela02.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/tela01',
      routes: {
        '/tela01': (context) => Tela01(),
        '/Tela02': (context) => Tela02(),
        '/Tela03': (context) => Tela03(),
      },
    );
  }
}

class Tela01 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tela 01'), backgroundColor: Colors.blue),
      body: Column(
        children: [
          Center(
            child: ElevatedButton(
              child: Text('tela02'),
              onPressed: () {
                print('Clicou');
                Navigator.pushNamed(context, '/Tela02'); // ✅ corrigido
              },
            ),
          ),
          Center(
            child: ElevatedButton(
              child: Text('tela03'),
              onPressed: () {
                Navigator.pushNamed(context, '/Tela03'); // ✅ corrigido
              },
            ),
          ),
        ],
      ),
    );
  }
}

class Tela03 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tela 03 '), backgroundColor: Colors.green),
      body: Column(
        children: [
          Center(
            child: ElevatedButton(
              child: Text('Tela 1'),
              onPressed: () {
                Navigator.pushNamed(context, '/tela01');
              },
            ),
          ),
          Center(
            child: ElevatedButton(
              child: Text('Tela 2'),
              onPressed: () {
                Navigator.pushNamed(context, '/Tela02');
              },
            ),
          ),
          Center(
            child: ElevatedButton(
              child: Text('voltar'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
