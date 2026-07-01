import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../widgets/drawer_widget.dart';

class FinanceiroScreen extends StatefulWidget {
  @override
  _FinanceiroScreenState createState() => _FinanceiroScreenState();
}

class _FinanceiroScreenState extends State<FinanceiroScreen> {
  final FirestoreService _firestore = FirestoreService();
  
  // Paleta de cores pastel gamer
  static const Color primaryPastel = Color(0xFFB8A9C9);
  static const Color secondaryPastel = Color(0xFFC9E4E7);
  static const Color accentPastel = Color(0xFFFFD4B8);
  static const Color backgroundDark = Color(0xFF2D2B3D);
  static const Color cardColor = Color(0xFF3D3B4F);
  static const Color textLight = Color(0xFFF0E6FF);
  static const Color successGreen = Color(0xFFB8E6C8);
  static const Color errorRed = Color(0xFFFFB8B8);

  Future<void> _mostrarDialogRetirada() async {
    final valorController = TextEditingController();
    final descricaoController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: primaryPastel.withOpacity(0.3)),
        ),
        title: Row(
          children: [
            Icon(Icons.money_off, color: errorRed),
            const SizedBox(width: 10),
            Text(
              'Registrar Retirada',
              style: TextStyle(color: textLight, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: valorController,
              keyboardType: TextInputType.number,
              style: TextStyle(color: textLight),
              decoration: InputDecoration(
                labelText: 'Valor (R\$)',
                labelStyle: TextStyle(color: textLight.withOpacity(0.7)),
                prefixIcon: Icon(Icons.attach_money, color: accentPastel),
                filled: true,
                fillColor: backgroundDark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryPastel.withOpacity(0.3)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descricaoController,
              style: TextStyle(color: textLight),
              decoration: InputDecoration(
                labelText: 'Descrição',
                labelStyle: TextStyle(color: textLight.withOpacity(0.7)),
                prefixIcon: Icon(Icons.description, color: secondaryPastel),
                filled: true,
                fillColor: backgroundDark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryPastel.withOpacity(0.3)),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: TextStyle(color: errorRed)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (valorController.text.isEmpty || descricaoController.text.isEmpty) {
                return;
              }
              await _firestore.registrarRetirada(
                valor: double.parse(valorController.text),
                descricao: descricaoController.text,
                responsavel: 'Gerente',
              );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white),
                      const SizedBox(width: 8),
                      Text('Retirada registrada!', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                  backgroundColor: successGreen.withOpacity(0.9),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: errorRed,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Registrar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundDark,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        title: Row(
          children: [
            Icon(Icons.account_balance, color: successGreen),
            const SizedBox(width: 10),
            Text(
              'Financeiro',
              style: TextStyle(color: textLight, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: errorRed.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: errorRed.withOpacity(0.3)),
            ),
            child: IconButton(
              icon: Icon(Icons.money_off, color: errorRed),
              onPressed: _mostrarDialogRetirada,
            ),
          ),
        ],
      ),
      drawer: DrawerWidget(),
      body: Column(
        children: [
          // Card do saldo
          FutureBuilder<double>(
            future: _firestore.getSaldoAtual(),
            builder: (context, snapshot) {
              double saldo = snapshot.data ?? 0;
              return Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [successGreen.withOpacity(0.2), secondaryPastel.withOpacity(0.1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: successGreen.withOpacity(0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: successGreen.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'SALDO ATUAL',
                      style: TextStyle(
                        color: textLight.withOpacity(0.7),
                        fontSize: 14,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'R\$ ${saldo.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: successGreen,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          
          // Tabs de Vendas e Retiradas
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  TabBar(
                    labelColor: primaryPastel,
                    unselectedLabelColor: textLight.withOpacity(0.5),
                    indicatorColor: primaryPastel,
                    tabs: [
                      Tab(text: 'Vendas'),
                      Tab(text: 'Retiradas'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildVendasList(),
                        _buildRetiradasList(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVendasList() {
    return StreamBuilder(
      stream: _firestore.streamVendas(),
      builder: (context, AsyncSnapshot<dynamic> snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(color: primaryPastel),
          );
        }
        
        var docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return Center(
            child: Text('Nenhuma venda realizada', style: TextStyle(color: textLight.withOpacity(0.7))),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            var data = docs[index].data();
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: primaryPastel.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'R\$ ${(data['total'] ?? 0).toStringAsFixed(2)}',
                        style: TextStyle(
                          color: successGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${(data['itens'] as List).length} itens',
                        style: TextStyle(color: textLight.withOpacity(0.6), fontSize: 12),
                      ),
                    ],
                  ),
                  Icon(Icons.arrow_forward_ios, color: textLight.withOpacity(0.5), size: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRetiradasList() {
    return StreamBuilder(
      stream: _firestore.streamFinanceiro(),
      builder: (context, AsyncSnapshot<dynamic> snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(color: errorRed),
          );
        }
        
        var docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return Center(
            child: Text('Nenhuma retirada registrada', style: TextStyle(color: textLight.withOpacity(0.7))),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            var data = docs[index].data();
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: errorRed.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['descricao'] ?? '',
                        style: TextStyle(color: textLight, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        'R\$ ${(data['valor'] ?? 0).toStringAsFixed(2)}',
                        style: TextStyle(
                          color: errorRed,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Icon(Icons.money_off, color: errorRed.withOpacity(0.5), size: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }
}