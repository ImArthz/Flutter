import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';
import '../models/produto_model.dart';
import '../providers/usuario_provider.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/drawer_widget.dart';

class ProdutosScreen extends StatefulWidget {
  @override
  _ProdutosScreenState createState() => _ProdutosScreenState();
}

class _ProdutosScreenState extends State<ProdutosScreen> {
  final FirestoreService _firestore = FirestoreService();
  final _formKey = GlobalKey<FormState>();
  final _codigoController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _estoqueController = TextEditingController();
  final _precoController = TextEditingController();
  String? _editingId;

  @override
  void dispose() {
    _codigoController.dispose();
    _descricaoController.dispose();
    _estoqueController.dispose();
    _precoController.dispose();
    super.dispose();
  }

  void _showDialog({Produto? produto}) {
    if (produto != null) {
      _editingId = produto.id;
      _codigoController.text = produto.codigo;
      _descricaoController.text = produto.descricao;
      _estoqueController.text = produto.quantidadeEstoque.toString();
      _precoController.text = produto.precoUnitario.toStringAsFixed(2);
    } else {
      _editingId = null;
      _codigoController.clear();
      _descricaoController.clear();
      _estoqueController.clear();
      _precoController.clear();
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          produto == null ? 'Novo Produto' : 'Editar Produto',
          style: const TextStyle(color: Colors.white),
        ),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                controller: _codigoController,
                label: 'Código',
                icon: Icons.code,
                validator: (v) => v!.isEmpty ? 'Digite o código' : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _descricaoController,
                label: 'Descrição',
                icon: Icons.description,
                validator: (v) => v!.isEmpty ? 'Digite a descrição' : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _estoqueController,
                label: 'Quantidade em Estoque',
                icon: Icons.inventory,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v!.isEmpty) return 'Digite o estoque';
                  if (int.tryParse(v) == null) return 'Número válido';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _precoController,
                label: 'Preço Unitário (R\$)',
                icon: Icons.attach_money,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v!.isEmpty) return 'Digite o preço';
                  if (double.tryParse(v) == null) return 'Preço válido';
                  return null;
                },
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
                final produto = Produto(
                  id: _editingId ?? '',
                  codigo: _codigoController.text,
                  descricao: _descricaoController.text,
                  quantidadeEstoque: int.parse(_estoqueController.text),
                  precoUnitario: double.parse(_precoController.text),
                );
                if (_editingId == null) {
                  await _firestore.adicionarProduto(produto);
                } else {
                  await _firestore.atualizarProduto(_editingId!, produto.toMap());
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
    final usuarioProvider = Provider.of<UsuarioProvider>(context);
    final podeEditar = usuarioProvider.podeCadastrarProdutos;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Produtos'),
        actions: [
          if (podeEditar)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showDialog(),
            ),
        ],
      ),
      drawer: DrawerWidget(),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.streamProdutos(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          var docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('Nenhum produto cadastrado.'));
          }
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (ctx, index) {
              var data = docs[index].data() as Map<String, dynamic>;
              var produto = Produto.fromMap(docs[index].id, data);
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(produto.descricao, style: const TextStyle(color: Colors.white)),
                  subtitle: Text(
                    'Cód: ${produto.codigo} | Estoque: ${produto.quantidadeEstoque} | R\$ ${produto.precoUnitario.toStringAsFixed(2)}',
                  ),
                  trailing: podeEditar
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showDialog(produto: produto),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                await _firestore.deletarProduto(produto.id);
                              },
                            ),
                          ],
                        )
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}