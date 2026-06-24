import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/usuario_provider.dart';
import '../widgets/drawer_widget.dart';
import 'clientes_screen.dart';
import 'produtos_screen.dart';
import 'vendas_screen.dart';
import 'gerenciar_usuarios_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _telas = [
    VendasScreen(),
    ClientesScreen(),
    ProdutosScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final usuarioProvider = Provider.of<UsuarioProvider>(context);
    final isGerente = usuarioProvider.isGerente;

    return Scaffold(
      appBar: AppBar(
        title: Text('GameStore'),
        actions: [
          if (isGerente)
            IconButton(
              icon: Icon(Icons.admin_panel_settings),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => GerenciarUsuariosScreen()),
                );
              },
            ),
        ],
      ),
      drawer: DrawerWidget(),
      body: _telas[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        backgroundColor: Color(0xFF1E1E1E),
        selectedItemColor: Color(0xFF7B2FBE),
        unselectedItemColor: Colors.white54,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Vendas'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Clientes'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory), label: 'Produtos'),
        ],
      ),
    );
  }
}