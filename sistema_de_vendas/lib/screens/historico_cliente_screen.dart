import 'package:flutter/material.dart';
import '../models/cliente_model.dart';
import '../models/venda_model.dart';
import '../services/firestore_service.dart';

class HistoricoClienteScreen extends StatefulWidget {
  final Cliente cliente;

  const HistoricoClienteScreen({required this.cliente});

  @override
  _HistoricoClienteScreenState createState() => _HistoricoClienteScreenState();
}

class _HistoricoClienteScreenState extends State<HistoricoClienteScreen> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundDark,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        title: Row(
          children: [
            Icon(Icons.history, color: primaryPastel),
            const SizedBox(width: 10),
            Text(
              'Histórico de Compras',
              style: TextStyle(color: textLight, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<Venda>>(
        future: _firestore.getVendasPorCliente(widget.cliente.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: primaryPastel),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erro ao carregar histórico',
                style: TextStyle(color: errorRed),
              ),
            );
          }

          final vendas = snapshot.data ?? [];

          if (vendas.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    color: textLight.withOpacity(0.3),
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhuma compra realizada',
                    style: TextStyle(
                      color: textLight.withOpacity(0.7),
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            );
          }

          // Calcula total gasto
          double totalGasto = vendas.fold(0, (sum, venda) => sum + venda.total);

          return Column(
            children: [
              // Card com informações do cliente e total
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [cardColor, cardColor.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: primaryPastel.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: primaryPastel.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.person,
                            color: primaryPastel,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.cliente.nome,
                                style: TextStyle(
                                  color: textLight,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'CPF: ${widget.cliente.cpf}',
                                style: TextStyle(
                                  color: textLight.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: successGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: successGreen.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Gasto:',
                            style: TextStyle(color: textLight, fontSize: 16),
                          ),
                          Text(
                            'R\$ ${totalGasto.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: successGreen,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Lista de vendas
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: vendas.length,
                  itemBuilder: (context, index) {
                    final venda = vendas[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [cardColor, cardColor.withOpacity(0.8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: primaryPastel.withOpacity(0.2),
                        ),
                      ),
                      child: ExpansionTile(
                        backgroundColor: cardColor.withOpacity(0.5),
                        collapsedBackgroundColor: Colors.transparent,
                        iconColor: primaryPastel,
                        collapsedIconColor: textLight.withOpacity(0.5),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: accentPastel.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.shopping_bag,
                            color: accentPastel,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          'R\$ ${venda.total.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: successGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          '${venda.data.day}/${venda.data.month}/${venda.data.year} - ${venda.itens.length} itens',
                          style: TextStyle(
                            color: textLight.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: venda.itens.map((item) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item.descricao,
                                          style: TextStyle(
                                            color: textLight.withOpacity(0.8),
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '${item.quantidade}x R\$ ${item.precoUnitario.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          color: accentPastel,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
