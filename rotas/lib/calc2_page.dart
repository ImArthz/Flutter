import 'package:flutter/material.dart';

class Calcu extends StatefulWidget {
  const Calcu({super.key});

  @override
  State<Calcu> createState() => _CalcuState();
}

class _CalcuState extends State<Calcu> {
  String display = '0';
  int numero = 0;
  String? operador;
  double? num1;

  void adicionarnumero() {
    setState(() {
      if (display == '0') {
        display = numero.toString();
      } else {
        display += numero.toString();
      }
    });
  }

  void definirOperador(String op) {
    setState(() {
      num1 = double.parse(display);
      operador = op;
      display = '0';
    });
  }

  void calcular() {
    double num2 = double.parse(display);
    double resultado = 0;

    if (operador == '+') {
      resultado = num1! + num2;
    } else if (operador == '-') {
      resultado = num1! - num2;
    } else if (operador == '*') {
      resultado = num1! * num2;
    } else if (operador == '/') {
      resultado = num1! / num2;
    }

    setState(() {
      display = resultado.toString();
      if (display.endsWith('.0')) {
        display = display.substring(0, display.length - 2);
      }
      operador = null;
      num1 = null;
    });
  }

  void limparTudo() {
    setState(() {
      display = '0';
      operador = null;
      num1 = null;
    });
  }

  void apagarUltimo() {
    setState(() {
      if (display.length == 1) {
        display = '0';
      } else {
        display = display.substring(0, display.length - 1);
      }
    });
  }

  Widget botaoImagem(String img, VoidCallback onTap, {Color? bgColor}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: bgColor ?? Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black26, blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.asset(
            img,
            width: 65,
            height: 65,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 65,
                height: 65,
                color: bgColor ?? Colors.grey.shade300,
                child: const Icon(Icons.broken_image, color: Colors.red, size: 40),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget botaoTexto(String texto, VoidCallback onTap, {Color? bgColor, Color? textColor}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(6),
        width: 65,
        height: 65,
        decoration: BoxDecoration(
          color: bgColor ?? Colors.grey.shade300,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black26, blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        child: Center(
          child: Text(
            texto,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: textColor ?? Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget linha(List<Widget> botoes) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: botoes,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.indigo.shade50,
        appBar: AppBar(
          title: const Text('CALCULADORA', style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: Colors.deepPurpleAccent.shade100,

          // 🔙 BOTÃO DE VOLTAR
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 450),
            padding: const EdgeInsets.all(16),
            child: Card(
              elevation: 12,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(36)),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade900,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 6)],
                      ),
                      child: Text(
                        display,
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontSize: 42, fontFamily: 'monospace', color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 24),

                    linha([
                      botaoImagem('assets/number 7.png', () { numero = 7; adicionarnumero(); }, bgColor: Colors.blue.shade100),
                      botaoImagem('assets/number 8.png', () { numero = 8; adicionarnumero(); }, bgColor: Colors.blue.shade100),
                      botaoImagem('assets/number 9.png', () { numero = 9; adicionarnumero(); }, bgColor: Colors.blue.shade100),
                      botaoImagem('assets/operator plus.png', () => definirOperador('+'), bgColor: Colors.orange.shade200),
                    ]),
                    const SizedBox(height: 8),

                    linha([
                      botaoImagem('assets/number 6.png', () { numero = 6; adicionarnumero(); }, bgColor: Colors.blue.shade100),
                      botaoImagem('assets/number 5.png', () { numero = 5; adicionarnumero(); }, bgColor: Colors.blue.shade100),
                      botaoImagem('assets/number 4.png', () { numero = 4; adicionarnumero(); }, bgColor: Colors.blue.shade100),
                      botaoImagem('assets/operator minus.png', () => definirOperador('-'), bgColor: Colors.orange.shade200),
                    ]),
                    const SizedBox(height: 8),

                    linha([
                      botaoImagem('assets/number 3.png', () { numero = 3; adicionarnumero(); }, bgColor: Colors.blue.shade100),
                      botaoImagem('assets/number 2.png', () { numero = 2; adicionarnumero(); }, bgColor: Colors.blue.shade100),
                      botaoImagem('assets/number 1.png', () { numero = 1; adicionarnumero(); }, bgColor: Colors.blue.shade100),
                      botaoImagem('assets/operator multiplication.png', () => definirOperador('*'), bgColor: Colors.orange.shade200),
                    ]),
                    const SizedBox(height: 8),

                    linha([
                      botaoImagem('assets/number 0.png', () { numero = 0; adicionarnumero(); }, bgColor: Colors.blue.shade100),
                      botaoImagem('assets/operator equal.png', calcular, bgColor: Colors.green.shade300),
                      botaoImagem('assets/operator division.png', () => definirOperador('/'), bgColor: Colors.orange.shade200),
                    ]),
                    const SizedBox(height: 8),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        botaoTexto('C', limparTudo, bgColor: Colors.red.shade400, textColor: Colors.white),
                        botaoTexto('⌫', apagarUltimo, bgColor: Colors.purple.shade400, textColor: Colors.white),
                        const SizedBox(width: 65),
                        const SizedBox(width: 65),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}