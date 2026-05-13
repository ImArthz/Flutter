import 'package:flutter/material.dart';

class Tela02 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tela 02'),
        backgroundColor: Colors.orange,
      ),
      body: Column(
        children: [
          Center(
            child: ElevatedButton(
              child: Text('tela03'),
              onPressed: () {
                Navigator.pushNamed(context, '/Tela03'); // voltargit init
              },
            ),
          ),
          Center(
            child: ElevatedButton(
              child: Text('tela01'),
              onPressed: () {
                Navigator.pushNamed(context, '/tela01'); // voltar
              },
            ),
          ),
        ],
      ),
    );
  }
}
/*criar a tela 03 

tela 03 

t1 -> vai para tela 01 
t2 -> vai para tela 02 
voltar -> volta para anterior


*adicionar nas telas 1 e 02 para ir na tela03
*/ 