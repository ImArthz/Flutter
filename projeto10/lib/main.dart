import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class item {
  int userId = 0, id = 0;
  String title = '';
  bool completed = false;

  item(this.userId, this.id, this.title, this.completed);

  factory item.fromJson(Map<String, dynamic> Dados) =>
      item(Dados['userId'], Dados['id'], Dados['title'], Dados['completed']);

  Map<String, dynamic> toJson() => {
    'userId': this.userId,
    'id': this.id,
    'title': this.title,
    'completed': this.completed,
  };
}

void main() {
  runApp(const MaterialApp(home: httplist()));
}

class httplist extends StatefulWidget {
  const httplist({super.key});

  @override
  State<httplist> createState() => _httplistState();
}

class _httplistState extends State<httplist> {
  List<item> lista = [];
  int index = 0;

  @override
  void initState() {
    super.initState();
    carregar();
  }

  void carregar() {
    Uri uri = Uri.https('jsonplaceholder.typicode.com', '/todos/');
    final future = http.get(uri);

    future.then((response) {
      if (response.statusCode == 200) {
        print('conectado');

        List<dynamic> dados = json.decode(response.body);

        //Map<String,dynamic> Dados = json.decode(response.body);
        //item tmp = item(Dados['userId'],Dados['id'],Dados['title'],Dados['completed']);
        //print ("${tmp.userId}-${tmp.Id}-${tmp.title}-${tmp.completed}");
        //item tmp = item.fromJson(Dados);
        //print("${tmp.userId}.${tmp.title},${tmp.id},${tmp.completed}");
        //print(tmp.toJson());

        List<item> temp = [];

        for (var elemento in dados) {
          item tmp = item.fromJson(elemento);
          temp.add(tmp);
        }

        setState(() {
          lista = temp;
        });

        print(dados.length); // confirmar
      } else {
        print('Erro de conexão');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (lista.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    item atual = lista[index];

    return Scaffold(
      appBar: AppBar(title: Text('Trabado Programação dispositivos movéis ')),
      backgroundColor: Colors.grey[200],
      body: Center(
        child: Container(
          width: 300,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // JSON titulo central
              Text(
                'JSON',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),

              SizedBox(height: 10),

              Divider(),

              SizedBox(height: 15),

              // titulo
              TextField(
                readOnly: true,
                controller: TextEditingController(text: atual.title),
                decoration: InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(),
                ),
              ),

              SizedBox(height: 15),

              // status
              TextField(
                readOnly: true,
                controller: TextEditingController(
                  text: atual.completed ? 'finalizado' : 'pendente',
                ),
                decoration: InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
              ),

              SizedBox(height: 15),

              // id
              TextField(
                readOnly: true,
                controller: TextEditingController(text: atual.id.toString()),
                decoration: InputDecoration(
                  labelText: 'ID',
                  border: OutlineInputBorder(),
                ),
              ),

              SizedBox(height: 15),

              // userId
              TextField(
                readOnly: true,
                controller: TextEditingController(
                  text: atual.userId.toString(),
                ),
                decoration: InputDecoration(
                  labelText: 'UserId',
                  border: OutlineInputBorder(),
                ),
              ),

              SizedBox(height: 20),

              // botoes <<
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // ANTERIOR <<
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: index > 0
                        ? () {
                            setState(() {
                              index--;
                            });
                          }
                        : null,
                    child: Text(
                      '<<',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // PROXIMO >>
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: index < lista.length - 1
                        ? () {
                            setState(() {
                              index++;
                            });
                          }
                        : null,
                    child: Text(
                      '>>',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
