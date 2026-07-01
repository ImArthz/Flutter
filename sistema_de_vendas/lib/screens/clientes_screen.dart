import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../models/cliente_model.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/drawer_widget.dart';
import '../screens/historico_cliente_screen.dart';

class ClientesScreen extends StatefulWidget {
  @override
  _ClientesScreenState createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  final FirestoreService _firestore = FirestoreService();
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _cpfController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _enderecoController = TextEditingController();
  String? _editingId;

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
  void dispose() {
    _nomeController.dispose();
    _cpfController.dispose();
    _telefoneController.dispose();
    _enderecoController.dispose();
    super.dispose();
  }

  void _showDialog({Cliente? cliente}) {
    if (cliente != null) {
      _editingId = cliente.id;
      _nomeController.text = cliente.nome;
      _cpfController.text = cliente.cpf;
      _telefoneController.text = cliente.telefone;
      _enderecoController.text = cliente.endereco;
    } else {
      _editingId = null;
      _nomeController.clear();
      _cpfController.clear();
      _telefoneController.clear();
      _enderecoController.clear();
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: primaryPastel.withOpacity(0.3), width: 1),
        ),
        title: Row(
          children: [
            Icon(
              cliente == null ? Icons.person_add : Icons.edit,
              color: primaryPastel,
              size: 24,
            ),
            const SizedBox(width: 10),
            Text(
              cliente == null ? 'Novo Cliente' : 'Editar Cliente',
              style: TextStyle(color: textLight, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                controller: _nomeController,
                label: 'Nome',
                icon: Icons.person,
                validator: (v) => v!.isEmpty ? 'Digite o nome' : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _cpfController,
                label: 'CPF',
                icon: Icons.credit_card,
                validator: (v) => v!.isEmpty ? 'Digite o CPF' : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _telefoneController,
                label: 'Telefone',
                icon: Icons.phone,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _enderecoController,
                label: 'Endereço',
                icon: Icons.home,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(color: errorRed, fontWeight: FontWeight.w500),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final cliente = Cliente(
                  id: _editingId ?? '',
                  nome: _nomeController.text,
                  cpf: _cpfController.text,
                  telefone: _telefoneController.text,
                  endereco: _enderecoController.text,
                );
                if (_editingId == null) {
                  await _firestore.adicionarCliente(cliente);
                } else {
                  await _firestore.atualizarCliente(_editingId!, cliente.toMap());
                }
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryPastel,
              foregroundColor: backgroundDark,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              'Salvar',
              style: TextStyle(color: backgroundDark, fontWeight: FontWeight.w600),
            ),
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
            Icon(Icons.people, color: primaryPastel),
            const SizedBox(width: 10),
            Text(
              'Clientes',
              style: TextStyle(color: textLight, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: primaryPastel.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: primaryPastel.withOpacity(0.3)),
            ),
            child: IconButton(
              icon: Icon(Icons.add, color: primaryPastel),
              onPressed: () => _showDialog(),
            ),
          ),
        ],
      ),
      drawer: DrawerWidget(),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.streamClientes(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: errorRed, size: 48),
                  const SizedBox(height: 16),
                  Text('Erro: ${snapshot.error}', style: TextStyle(color: errorRed)),
                ],
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: primaryPastel));
          }
          var docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, color: primaryPastel.withOpacity(0.5), size: 64),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum cliente cadastrado.',
                    style: TextStyle(color: textLight.withOpacity(0.7), fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Toque no + para adicionar',
                    style: TextStyle(color: accentPastel.withOpacity(0.6), fontSize: 14),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (ctx, index) {
              var data = docs[index].data() as Map<String, dynamic>;
              var cliente = Cliente.fromMap(docs[index].id, data);
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [cardColor, cardColor.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: primaryPastel.withOpacity(0.2), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: primaryPastel.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      // Ícone do cliente
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: primaryPastel.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.person, color: primaryPastel, size: 28),
                      ),
                      const SizedBox(width: 12),
                      // Informações do cliente
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cliente.nome,
                              style: TextStyle(
                                color: textLight,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.credit_card, size: 14, color: secondaryPastel),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    'CPF: ${cliente.cpf}',
                                    style: TextStyle(color: textLight.withOpacity(0.7), fontSize: 13),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(Icons.phone, size: 14, color: accentPastel),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    'Tel: ${cliente.telefone}',
                                    style: TextStyle(color: textLight.withOpacity(0.7), fontSize: 13),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Botões de ação
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Histórico
                              Container(
                                decoration: BoxDecoration(
                                  color: successGreen.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: IconButton(
                                  icon: Icon(Icons.history, color: successGreen, size: 20),
                                  tooltip: 'Histórico de Compras',
                                  padding: const EdgeInsets.all(6),
                                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => HistoricoClienteScreen(cliente: cliente),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 4),
                              // Editar
                              Container(
                                decoration: BoxDecoration(
                                  color: secondaryPastel.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: IconButton(
                                  icon: Icon(Icons.edit, color: secondaryPastel, size: 20),
                                  padding: const EdgeInsets.all(6),
                                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                                  onPressed: () => _showDialog(cliente: cliente),
                                ),
                              ),
                              const SizedBox(width: 4),
                              // Excluir
                              Container(
                                decoration: BoxDecoration(
                                  color: errorRed.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: IconButton(
                                  icon: Icon(Icons.delete, color: errorRed, size: 20),
                                  padding: const EdgeInsets.all(6),
                                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                                  onPressed: () async {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        backgroundColor: cardColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                          side: BorderSide(color: primaryPastel.withOpacity(0.3), width: 1),
                                        ),
                                        title: Row(
                                          children: [
                                            Icon(Icons.warning_amber_rounded, color: errorRed),
                                            const SizedBox(width: 10),
                                            Text('Confirmar exclusão', style: TextStyle(color: textLight)),
                                          ],
                                        ),
                                        content: Text(
                                          'Deseja realmente excluir ${cliente.nome}?',
                                          style: TextStyle(color: textLight.withOpacity(0.8)),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: Text('Cancelar', style: TextStyle(color: secondaryPastel)),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              _firestore.deletarCliente(cliente.id);
                                              Navigator.pop(context);
                                            },
                                            child: Text(
                                              'Excluir',
                                              style: TextStyle(color: errorRed, fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}