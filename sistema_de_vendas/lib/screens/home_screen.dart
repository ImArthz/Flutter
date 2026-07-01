import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/usuario_provider.dart';
import '../widgets/drawer_widget.dart';
import 'clientes_screen.dart';
import 'produtos_screen.dart';
import 'vendas_screen.dart';
import 'gerenciar_usuarios_screen.dart';
import 'financeiro_screen.dart';


class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Paleta de cores pastel gamer
  static const Color primaryPastel = Color(0xFFB8A9C9); // Roxo pastel
  static const Color secondaryPastel = Color(0xFFC9E4E7); // Azul pastel
  static const Color accentPastel = Color(0xFFFFD4B8); // Laranja pastel
  static const Color backgroundDark = Color(0xFF2D2B3D); // Roxo escuro suave
  static const Color cardColor = Color(0xFF3D3B4F); // Card escuro pastel
  static const Color textLight = Color(0xFFF0E6FF); // Texto claro pastel
  static const Color successGreen = Color(0xFFB8E6C8); // Verde pastel
  static const Color errorRed = Color(0xFFFFB8B8); // Vermelho pastel

  final List<Widget> _telas = [
    VendasScreen(),
    ClientesScreen(),
    ProdutosScreen(),
  ];

  final List<Map<String, dynamic>> _navItems = [
    {
      'icon': Icons.shopping_cart,
      'label': 'Vendas',
      'activeIcon': Icons.shopping_cart,
    },
    {
      'icon': Icons.people_outline,
      'label': 'Clientes',
      'activeIcon': Icons.people,
    },
    {
      'icon': Icons.inventory_2_outlined,
      'label': 'Produtos',
      'activeIcon': Icons.inventory_2,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final usuarioProvider = Provider.of<UsuarioProvider>(context);
    final isGerente = usuarioProvider.isGerente;

    return Scaffold(
      backgroundColor: backgroundDark,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryPastel, secondaryPastel],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.sports_esports,
                color: backgroundDark,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'GameStore',
              style: TextStyle(
                color: textLight,
                fontWeight: FontWeight.w700,
                fontSize: 20,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          // Botão Financeiro (visível para todos)
          Container(
            margin: const EdgeInsets.only(right: 4),
            decoration: BoxDecoration(
              color: successGreen.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: successGreen.withOpacity(0.3)),
            ),
            child: IconButton(
              icon: Icon(Icons.account_balance, color: successGreen),
              tooltip: 'Financeiro',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => FinanceiroScreen()),
                );
              },
            ),
          ),
          if (isGerente)
            Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: primaryPastel.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: primaryPastel.withOpacity(0.3)),
              ),
              child: IconButton(
                icon: Icon(Icons.admin_panel_settings, color: primaryPastel),
                tooltip: 'Gerenciar Usuários',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GerenciarUsuariosScreen(),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
      drawer: DrawerWidget(),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _telas[_selectedIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [cardColor, cardColor.withOpacity(0.95)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          boxShadow: [
            BoxShadow(
              color: primaryPastel.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_navItems.length, (index) {
                final isSelected = _selectedIndex == index;
                return _buildNavItem(
                  icon: isSelected
                      ? _navItems[index]['activeIcon']
                      : _navItems[index]['icon'],
                  label: _navItems[index]['label'],
                  isSelected: isSelected,
                  onTap: () => setState(() => _selectedIndex = index),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    primaryPastel.withOpacity(0.3),
                    secondaryPastel.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: primaryPastel.withOpacity(0.4), width: 1)
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryPastel.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? primaryPastel : textLight.withOpacity(0.5),
              size: isSelected ? 28 : 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? primaryPastel : textLight.withOpacity(0.5),
                fontSize: isSelected ? 12 : 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
