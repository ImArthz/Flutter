import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/usuario_provider.dart';
import '../screens/login_screen.dart';
import '../screens/perfil_screen.dart';
import '../screens/financeiro_screen.dart';
import 'dart:convert';

class DrawerWidget extends StatelessWidget {
  static const Color primaryPastel = Color(0xFFB8A9C9);
  static const Color backgroundDark = Color(0xFF2D2B3D);
  static const Color cardColor = Color(0xFF3D3B4F);
  static const Color textLight = Color(0xFFF0E6FF);
  static const Color errorRed = Color(0xFFFFB8B8);
  static const Color successGreen = Color(0xFFB8E6C8);
  static const Color secondaryPastel = Color(0xFFC9E4E7);
  static const Color accentPastel = Color(0xFFFFD4B8);

  @override
  Widget build(BuildContext context) {
    final usuario = Provider.of<UsuarioProvider>(context).usuarioLogado;
    final auth = Provider.of<AuthProvider>(context);
    final isGerente = usuario?.nivel == 'gerente';

    return Drawer(
      backgroundColor: backgroundDark,
      child: Column(
        children: [
          // Header com foto clicável
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PerfilScreen()),
              );
            },
            child: UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryPastel, secondaryPastel],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              accountName: Text(
                usuario?.nome ?? 'Vendedor',
                style: TextStyle(
                  color: backgroundDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
              accountEmail: Text(
                usuario?.email ?? '',
                style: TextStyle(color: backgroundDark.withOpacity(0.8)),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: backgroundDark,
                backgroundImage:
                    usuario?.fotoBase64 != null &&
                        usuario!.fotoBase64!.isNotEmpty
                    ? MemoryImage(base64Decode(usuario.fotoBase64!))
                    : null,
                child:
                    usuario?.fotoBase64 == null || usuario!.fotoBase64!.isEmpty
                    ? Text(
                        usuario?.nome?.isNotEmpty == true
                            ? usuario!.nome[0].toUpperCase()
                            : '?',
                        style: TextStyle(fontSize: 28, color: primaryPastel),
                      )
                    : null,
              ),
            ),
          ),
          // Menu
          ListTile(
            leading: Icon(Icons.home, color: textLight.withOpacity(0.7)),
            title: Text(
              'Início',
              style: TextStyle(color: textLight.withOpacity(0.7)),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/home');
            },
          ),
          ListTile(
            leading: Icon(Icons.shopping_cart, color: successGreen),
            title: Text(
              'Vendas',
              style: TextStyle(color: textLight.withOpacity(0.7)),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/vendas');
            },
          ),
          ListTile(
            leading: Icon(Icons.people, color: primaryPastel),
            title: Text(
              'Clientes',
              style: TextStyle(color: textLight.withOpacity(0.7)),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/clientes');
            },
          ),
          ListTile(
            leading: Icon(Icons.inventory, color: secondaryPastel),
            title: Text(
              'Produtos',
              style: TextStyle(color: textLight.withOpacity(0.7)),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/produtos');
            },
          ),
          // Financeiro (visível para todos)
          ListTile(
            leading: Icon(Icons.account_balance, color: successGreen),
            title: Text(
              'Financeiro',
              style: TextStyle(color: textLight.withOpacity(0.7)),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => FinanceiroScreen()),
              );
            },
          ),
          if (isGerente) ...[
            Divider(color: textLight.withOpacity(0.2)),
            ListTile(
              leading: Icon(Icons.admin_panel_settings, color: primaryPastel),
              title: Text(
                'Gerenciar Usuários',
                style: TextStyle(color: primaryPastel),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/gerenciar_usuarios');
              },
            ),
          ],
          Divider(color: textLight.withOpacity(0.2)),
          // Perfil
          ListTile(
            leading: Icon(Icons.person, color: accentPastel),
            title: Text(
              'Meu Perfil',
              style: TextStyle(color: textLight.withOpacity(0.7)),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PerfilScreen()),
              );
            },
          ),
          // Sair
          ListTile(
            leading: Icon(Icons.logout, color: errorRed),
            title: Text('Sair', style: TextStyle(color: errorRed)),
            onTap: () async {
              await auth.logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
