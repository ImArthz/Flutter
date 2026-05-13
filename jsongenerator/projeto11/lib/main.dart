import 'package:flutter/material.dart';

class Projeto11 extends StatefulWidget {
  const Projeto11({super.key});

  @override
  State<Projeto11> createState() => _Projeto11State();
}

class _Projeto11State extends State<Projeto11> {
  List<String> listaProdutos = [];

  String imgSapato = 'assets/3191.jpg',
      imgChinelo = 'assets/26838.jpg',
      confirmed = 'assets/vverde.jpg';

  List<String> listaimagens = [];

  @override
  void initState() {
    super.initState();

    //listaProdutos.add("sapato");
    //listaProdutos.add("chinelo");

    for (int i = 1; i < 200; i++) {
      listaProdutos.add("sapato $i");
      listaProdutos.add('chinelo $i');

      listaimagens.add(imgSapato);
      listaimagens.add(imgChinelo);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("Lista view")),

        body: Center(
          child: SizedBox(
            width: 500,
            height: 500,

            child: ListView.builder(
              reverse: true,
              shrinkWrap: true,

              itemCount: listaProdutos.length,

              itemBuilder: (context, indice) {
                return ListTile(
                  title: Text(
                    '${listaProdutos[indice]}',
                    style: TextStyle(fontSize: 24, color: Colors.blue),
                  ),

                  leading: Image.asset(
                    listaimagens[indice],
                    width: 50,
                    height: 50,
                  ),

                  subtitle: Text('aproveite nossa black friday '),

                  onTap: () {
                    String imagemOriginal = listaimagens[indice];

                    setState(() {
                      listaimagens[indice] = confirmed;
                    });

                    showDialog(
                      context: context,

                      builder: (_) => AlertDialog(
                        title: Text('Aviso'),

                        content: Text(
                          'produto selecionado ${listaProdutos[indice]}',
                        ),

                        actions: [
                          TextButton(
                            onPressed: () {
                              setState(() {
                                // VOLTA PARA A IMAGEM ORIGINAL
                                listaimagens[indice] = imagemOriginal;
                              });

                              Navigator.pop(context);
                            },

                            child: Text('OK'),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),

        //body: ListView(
        //children: <Widget> [
        //Text('Sandalha'),
        //Text('sapato'),
        //Text('chinelo'),
        //]
        //)
      ),
    );
  }
}

void main() {
  runApp(Projeto11());
}
