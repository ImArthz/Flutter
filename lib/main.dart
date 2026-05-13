// apenda a utilizar o json generator
// e crie 200 jsons
// id , nome, telefone, endereço , foto de perfil ,observações
// foto de perfil deve vir de algum loren picsum
// criar o app abaixo ( mapeando os json em classes )
// _________________
// app de cadastro
// foto campo da foto
// id campo do id
// nome campo de nome
// telefone campo de telefone
// observações campo de observações
// <<<                  >>>
// __________________________
// na parte inferior da tela crie um listview para exibir os json cada Item do da listview deve ser formatado conforme
// ----------------------------------
// |   ----  nome da silva  ( negrito)|
// |  | ft |  (ddd)telefone           |
// |   ----    endereco               |
// |  |-----------------------------| |
// |  |__observação ________________| |
// -----------------------------------
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Item {
  String id;
  String nome;
  String telefone;
  String endereco;
  String fotoPerfil;
  String observacao;

  Item(
    this.id,
    this.nome,
    this.telefone,
    this.endereco,
    this.fotoPerfil,
    this.observacao,
  );

  factory Item.fromJson(Map<String, dynamic> dados) {
    return Item(
      dados['id'].toString(),
      dados['nome'].toString(),
      dados['telefone'].toString(),
      dados['endereco'].toString(),
      dados['fotoPerfil'].toString(),
      dados['observacao'].toString(),
    );
  }
}

void main() {
  runApp(
     MaterialApp(
      debugShowCheckedModeBanner: false,
      home: JsonGenerator(),
    ),
  );
}

class JsonGenerator extends StatefulWidget {
   JsonGenerator({super.key});

  @override
  State<JsonGenerator> createState() => _JsonGeneratorState();
}

class _JsonGeneratorState extends State<JsonGenerator> {
  List<Item> lista = [];
  int index = 0;
  int selectedIndex = 0;
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    carregar();
  }

  Future<void> carregar() async {
    Uri uri = Uri.parse(
      'https://api.json-generator.com/templates/2Dql-W9dyJBZ/data',
    );

     const token = '8669zehx27wi9u4riq4gnie3qlsj1i54bdipqf1y';

    try {
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> dados = json.decode(response.body);

        setState(() {
          lista = dados.map((e) => Item.fromJson(e)).toList();
          carregando = false;
          index = 0;
          selectedIndex = 0;
        });
      } else {
        setState(() {
          carregando = false;
        });
      }
    } catch (e) {
      setState(() {
        carregando = false;
      });
    }
  }

  void selecionarItem(int i) {
    setState(() {
      index = i;
      selectedIndex = i;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (carregando) {
      return  Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (lista.isEmpty) {
      return  Scaffold(
        body: Center(
          child: Text("Nenhum dado encontrado"),
        ),
      );
    }

    Item atual = lista[index];

    return Scaffold(
      appBar: AppBar(
        title:  Text('Projeto Json Generator Pdm'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      backgroundColor: Colors.grey[200],
      body: Padding(
        padding:  EdgeInsets.all(10),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding:  EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow:  [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                   Text(
                    'App de cadastro',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                   SizedBox(height: 12),
                  CircleAvatar(
                    radius: 42,
                    backgroundImage: NetworkImage(atual.fotoPerfil),
                  ),
                   SizedBox(height: 12),
                  Text(
                    "ID: ${atual.id}",
                    style:  TextStyle(fontSize: 14),
                  ),
                   SizedBox(height: 4),
                  Text(
                    "Nome: ${atual.nome}",
                    style:  TextStyle(fontSize: 15),
                  ),
                   SizedBox(height: 4),
                  Text(
                    "Telefone: ${atual.telefone}",
                    style:  TextStyle(fontSize: 15),
                  ),
                   SizedBox(height: 4),
                  Text(
                    "Endereço: ${atual.endereco}",
                    textAlign: TextAlign.center,
                    style:  TextStyle(fontSize: 14),
                  ),
                   SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding:  EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: Text(
                      atual.observacao,
                      textAlign: TextAlign.center,
                      style:  TextStyle(fontSize: 13),
                    ),
                  ),
                   SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 68,
                        height: 32,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          onPressed: index > 0
                              ? () {
                                  selecionarItem(index - 1);
                                }
                              : null,
                          child:  Text("<<<"),
                        ),
                      ),
                      Text(
                        "${index + 1} / ${lista.length}",
                        style:  TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(
                        width: 68,
                        height: 32,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          onPressed: index < lista.length - 1
                              ? () {
                                  selecionarItem(index + 1);
                                }
                              : null,
                          child:  Text(">>>"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
             SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: lista.length,
                itemBuilder: (context, i) {
                  Item item = lista[i];
                  bool selecionado = i == selectedIndex;

                  return Padding(
                    padding:  EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        selecionarItem(i);
                      },
                      child: AnimatedContainer(
                        duration:  Duration(milliseconds: 200),
                        padding:  EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: selecionado
                              ? Colors.blue.withOpacity(0.12)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selecionado
                                ? Colors.blue
                                : Colors.black12,
                            width: selecionado ? 1.5 : 1,
                          ),
                          boxShadow:  [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                item.fotoPerfil,
                                width: 54,
                                height: 54,
                                fit: BoxFit.cover,
                              ),
                            ),
                             SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    item.nome,
                                    style:  TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                   SizedBox(height: 3),
                                  Text(
                                    item.telefone,
                                    style:  TextStyle(fontSize: 13),
                                  ),
                                   SizedBox(height: 3),
                                  Text(
                                    item.endereco,
                                    style:  TextStyle(fontSize: 13),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                   SizedBox(height: 6),
                                  Container(
                                    width: double.infinity,
                                    padding:  EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.black12,
                                      ),
                                    ),
                                    child: Text(
                                      item.observacao,
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style:  TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}