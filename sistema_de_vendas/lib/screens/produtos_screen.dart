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

  // Paleta de cores pastel gamer
  static const Color primaryPastel = Color(0xFFB8A9C9); // Roxo pastel
  static const Color secondaryPastel = Color(0xFFC9E4E7); // Azul pastel
  static const Color accentPastel = Color(0xFFFFD4B8); // Laranja pastel
  static const Color backgroundDark = Color(0xFF2D2B3D); // Roxo escuro suave
  static const Color cardColor = Color(0xFF3D3B4F); // Card escuro pastel
  static const Color textLight = Color(0xFFF0E6FF); // Texto claro pastel
  static const Color successGreen = Color(0xFFB8E6C8); // Verde pastel
  static const Color errorRed = Color(0xFFFFB8B8); // Vermelho pastel

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
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: primaryPastel.withOpacity(0.3), width: 1),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: accentPastel.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                produto == null ? Icons.add_box : Icons.edit,
                color: accentPastel,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              produto == null ? 'Novo Produto' : 'Editar Produto',
              style: TextStyle(
                color: textLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
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
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: errorRed,
                fontWeight: FontWeight.w500,
              ),
            ),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: accentPastel,
              foregroundColor: backgroundDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Salvar',
              style: TextStyle(
                color: backgroundDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getEstoqueColor(int quantidade) {
    if (quantidade == 0) return errorRed;
    if (quantidade <= 5) return accentPastel;
    return successGreen;
  }

  IconData _getEstoqueIcon(int quantidade) {
  if (quantidade == 0) return Icons.remove_shopping_cart; // ou Icons.block
  if (quantidade <= 5) return Icons.inventory_outlined;
  return Icons.inventory;
}

  @override
  Widget build(BuildContext context) {
    final usuarioProvider = Provider.of<UsuarioProvider>(context);
    final podeEditar = usuarioProvider.podeCadastrarProdutos;

    return Scaffold(
      backgroundColor: backgroundDark,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        title: Row(
          children: [
            Icon(Icons.inventory_2, color: accentPastel),
            const SizedBox(width: 10),
            Text(
              'Produtos',
              style: TextStyle(
                color: textLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          if (podeEditar)
            Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: accentPastel.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: accentPastel.withOpacity(0.3)),
              ),
              child: IconButton(
                icon: Icon(Icons.add, color: accentPastel),
                onPressed: () => _showDialog(),
              ),
            ),
        ],
      ),
      drawer: DrawerWidget(),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.streamProdutos(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: errorRed, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Erro: ${snapshot.error}',
                    style: TextStyle(color: errorRed),
                  ),
                ],
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: accentPastel,
              ),
            );
          }
          var docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    color: accentPastel.withOpacity(0.5),
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum produto cadastrado.',
                    style: TextStyle(
                      color: textLight.withOpacity(0.7),
                      fontSize: 16,
                    ),
                  ),
                  if (podeEditar) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Toque no + para adicionar',
                      style: TextStyle(
                        color: accentPastel.withOpacity(0.6),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (ctx, index) {
              var data = docs[index].data() as Map<String, dynamic>;
              var produto = Produto.fromMap(docs[index].id, data);
              final estoqueColor = _getEstoqueColor(produto.quantidadeEstoque);
              final estoqueIcon = _getEstoqueIcon(produto.quantidadeEstoque);
              
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      cardColor,
                      cardColor.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: accentPastel.withOpacity(0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: accentPastel.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          accentPastel.withOpacity(0.2),
                          accentPastel.withOpacity(0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.shopping_bag,
                      color: accentPastel,
                      size: 28,
                    ),
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          produto.descricao,
                          style: TextStyle(
                            color: textLight,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              primaryPastel.withOpacity(0.3),
                              secondaryPastel.withOpacity(0.2),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: primaryPastel.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          'R\$ ${produto.precoUnitario.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: primaryPastel,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.code,
                            size: 14,
                            color: secondaryPastel,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Cód: ${produto.codigo}',
                            style: TextStyle(
                              color: textLight.withOpacity(0.7),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            estoqueIcon,
                            size: 16,
                            color: estoqueColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Estoque: ${produto.quantidadeEstoque} un.',
                            style: TextStyle(
                              color: estoqueColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (produto.quantidadeEstoque == 0) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: errorRed.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'ESGOTADO',
                                style: TextStyle(
                                  color: errorRed,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                          if (produto.quantidadeEstoque > 0 && produto.quantidadeEstoque <= 5) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: accentPastel.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'BAIXO',
                                style: TextStyle(
                                  color: accentPastel,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  trailing: podeEditar
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: secondaryPastel.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: IconButton(
                                icon: Icon(Icons.edit, color: secondaryPastel, size: 20),
                                onPressed: () => _showDialog(produto: produto),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: errorRed.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: IconButton(
                                icon: Icon(Icons.delete, color: errorRed, size: 20),
                                onPressed: () async {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      backgroundColor: cardColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        side: BorderSide(
                                          color: primaryPastel.withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                      title: Row(
                                        children: [
                                          Icon(Icons.warning_amber_rounded, color: errorRed),
                                          const SizedBox(width: 10),
                                          Text(
                                            'Confirmar exclusão',
                                            style: TextStyle(color: textLight),
                                          ),
                                        ],
                                      ),
                                      content: Text(
                                        'Deseja realmente excluir ${produto.descricao}?',
                                        style: TextStyle(color: textLight.withOpacity(0.8)),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: Text(
                                            'Cancelar',
                                            style: TextStyle(color: secondaryPastel),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            _firestore.deletarProduto(produto.id);
                                            Navigator.pop(context);
                                          },
                                          child: Text(
                                            'Excluir',
                                            style: TextStyle(
                                              color: errorRed,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
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