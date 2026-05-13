import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Meu aplicativo')),

        drawer: Drawer(
          child: Builder(
            builder: (context) {
              return Column(
                children: [
                  ListTile(
                    title: const Text('Financeiro'),
                    subtitle:
                        const Text('Saldo, Extrato, Crédito'),
                    leading: const Icon(
                      Icons.attach_money,
                      color: Colors.green,
                    ),
                    onTap: () {
                      Navigator.pop(context); 

                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Aviso'),
                          content: const Text(
                              'Você clicou em financeiro'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); 
                                print('Clicou OK');
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  ListTile(
                    title: const Text('Patrimônio'),
                    subtitle: const Text(
                        'Imóveis, Veículos e etc'),
                    leading: const Icon(
                      Icons.house,
                      color: Colors.blue,
                    ),
                    onTap: () {
                      Navigator.pop(context); // fecha o drawer

                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text(
                              'Você acionou o modo patrimônio'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                print('Efetivou cadastro');
                              },
                              child: const Text(
                                  'Efetivar cadastro'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('Sair'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),

        bottomNavigationBar: Builder(
          builder: (context) {
            return BottomNavigationBar(
              
              onTap: (index){
                if(index == 0){
                  mostraMensgaem(context, 'voce clicou em pagina inicial ');
                }
                else if(index == 1){
                  mostraMensgaem(context, 'voce clicou em pagina procurar ');
                }
                else if(index == 2){
                  mostraMensgaem(context, 'voce clicou em pagina perfil ');
                }
                else if(index == 3){
                  mostraMensgaem(context, 'voce clicou em pagina chat ');
                }
                else if(index == 4){
                  mostraMensgaem(context, 'voce clicou em pagina ajuda ');
                }
              },
              backgroundColor: Colors.lightBlueAccent,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.grey,
              items: const [
                BottomNavigationBarItem(
                  label: 'Início',
                  icon: Icon(Icons.home),
                ),
                BottomNavigationBarItem(
                  label: 'Procurar',
                  icon: Icon(Icons.search),
                ),
                BottomNavigationBarItem(
                  label: 'Perfil',
                  icon: Icon(Icons.person),
                ),
                BottomNavigationBarItem(
                  label: 'Chat',
                  icon: Icon(Icons.chat),
                ),
                BottomNavigationBarItem(
                  label: 'Ajuda',
                  icon: Icon(Icons.help),
                ),
              ],
            );
          }
        ),
      ),
    );
  }
}
void mostraMensgaem(BuildContext context, String msg){
  showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title:  Text('Aviso'),
                              content:  Text(
                                  msg),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context); 
                                    print('Clicou OK');
                                  },
                                  child:  Text('OK'),
                                ),
                              ],
                            ),
                          );

}
void main() {
  runApp(const MyApp());
}