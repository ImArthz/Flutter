import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../models/cliente_model.dart';
import '../widgets/custom_text_field.dart';

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
  String? _editingId; // Armazena ID do cliente em edição

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
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          cliente == null ? 'Novo Cliente' : 'Editar Cliente',
          style: const TextStyle(color: Colors.white),
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
            child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
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
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showDialog(),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.streamClientes(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          var docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('Nenhum cliente cadastrado.'));
          }
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (ctx, index) {
              var data = docs[index].data() as Map<String, dynamic>;
              var cliente = Cliente.fromMap(docs[index].id, data);
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(cliente.nome, style: const TextStyle(color: Colors.white)),
                  subtitle: Text('CPF: ${cliente.cpf} | Telefone: ${cliente.telefone}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showDialog(cliente: cliente),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await _firestore.deletarCliente(cliente.id);
                        },
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