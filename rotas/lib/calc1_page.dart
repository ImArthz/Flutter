import 'package:flutter/material.dart';

class Calc1Page extends StatefulWidget {
  @override
  _Calc1PageState createState() => _Calc1PageState();
}

class _Calc1PageState extends State<Calc1Page> {
  TextEditingController valor1Controller = TextEditingController();
  TextEditingController valor2Controller = TextEditingController();

  bool soma = false;
  bool subtracao = false;
  bool multiplicacao = false;
  bool divisao = false;

  String resultado = '';

  void calcular() {
    double v1 = double.tryParse(valor1Controller.text) ?? 0;
    double v2 = double.tryParse(valor2Controller.text) ?? 0;

    List<String> resultados = [];

    if (soma) {
      resultados.add("Soma = ${v1 + v2}");
    }
    if (subtracao) {
      resultados.add("Subtração = ${v1 - v2}");
    }
    if (multiplicacao) {
      resultados.add("Multiplicação = ${v1 * v2}");
    }
    if (divisao) {
      if (v2 != 0) {
        resultados.add("Divisão = ${v1 / v2}");
      } else {
        resultados.add("Divisão = erro (divisão por 0)");
      }
    }

    setState(() {
      resultado = resultados.join(' | ');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calculadora'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: valor1Controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Valor 1'),
            ),
            TextField(
              controller: valor2Controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Valor 2'),
            ),

            CheckboxListTile(
              title: Text('Soma'),
              value: soma,
              onChanged: (value) {
                setState(() => soma = value!);
              },
            ),
            CheckboxListTile(
              title: Text('Subtração'),
              value: subtracao,
              onChanged: (value) {
                setState(() => subtracao = value!);
              },
            ),
            CheckboxListTile(
              title: Text('Multiplicação'),
              value: multiplicacao,
              onChanged: (value) {
                setState(() => multiplicacao = value!);
              },
            ),
            CheckboxListTile(
              title: Text('Divisão'),
              value: divisao,
              onChanged: (value) {
                setState(() => divisao = value!);
              },
            ),

            ElevatedButton(
              onPressed: calcular,
              child: Text('Calcular'),
            ),

            SizedBox(height: 20),

            Text(
              resultado,
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}