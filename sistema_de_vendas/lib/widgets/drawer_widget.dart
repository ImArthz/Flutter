import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/usuario_provider.dart';

class DrawerWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final usuario = Provider.of<UsuarioProvider>(context).usuarioLogado;
    final auth = Provider.of<AuthProvider>(context);

    return Drawer(
      backgroundColor: Color(0xFF1E1E1E),
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF7B2FBE), Color(0xFF4A148C)],
              ),
            ),
            accountName: Text(usuario?.nome ?? 'Vendedor'),
            accountEmail: Text(usuario?.email ?? ''),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                usuario?.nome?.isNotEmpty == true ? usuario!.nome[0].toUpperCase() : '?',
                style: TextStyle(fontSize: 28, color: Color(0xFF7B2FBE)),
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home, color: Colors.white70),
            title: Text('Início', style: TextStyle(color: Colors.white70)),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: Icon(Icons.shopping_cart, color: Colors.white70),
            title: Text('Vendas', style: TextStyle(color: Colors.white70)),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/home');
            },
          ),
          ListTile(
            leading: Icon(Icons.people, color: Colors.white70),
            title: Text('Clientes', style: TextStyle(color: Colors.white70)),
            onTap: () {
              Navigator.pop(context);
              // Navegar para clientes (já está no bottom nav)
            },
          ),
          ListTile(
            leading: Icon(Icons.inventory, color: Colors.white70),
            title: Text('Produtos', style: TextStyle(color: Colors.white70)),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          Divider(color: Colors.white24),
          ListTile(
            leading: Icon(Icons.exit_to_app, color: Colors.redAccent),
            title: Text('Sair', style: TextStyle(color: Colors.redAccent)),
            onTap: () async {
              await auth.logout();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}