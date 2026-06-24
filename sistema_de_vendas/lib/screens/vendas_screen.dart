import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';
import '../models/cliente_model.dart';
import '../models/produto_model.dart';
import '../models/venda_model.dart';
import '../providers/carrinho_provider.dart';
import '../providers/usuario_provider.dart';
import '../providers/auth_provider.dart';

class VendasScreen extends StatefulWidget {
  @override
  _VendasScreenState createState() => _VendasScreenState();
}

class _VendasScreenState extends State<VendasScreen> {
  final FirestoreService _firestore = FirestoreService();
  Cliente? _clienteSelecionado;
  Produto? _produtoSelecionado;
  int _quantidade = 1;

  @override
  Widget build(BuildContext context) {
    final carrinho = Provider.of<CarrinhoProvider>(context);
    final usuarioProvider = Provider.of<UsuarioProvider>(context);
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Nova Venda'),
        actions: [
          IconButton(
            icon: Icon(Icons.clear_all),
            onPressed: carrinho.limparCarrinho,
          ),
        ],
      ),
      body: Column(
        children: [
          // Selecionar Cliente
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Cliente', style: TextStyle(color: Colors.white70)),
                    SizedBox(height: 8),
                    _clienteSelecionado == null
                        ? ElevatedButton.icon(
                            onPressed: _selecionarCliente,
                            icon: Icon(Icons.person_add),
                            label: Text('Selecionar Cliente'),
                          )
                        : ListTile(
                            title: Text(_clienteSelecionado!.nome, style: TextStyle(color: Colors.white)),
                            subtitle: Text('CPF: ${_clienteSelecionado!.cpf}'),
                            trailing: IconButton(
                              icon: Icon(Icons.close, color: Colors.red),
                              onPressed: () => setState(() => _clienteSelecionado = null),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),

          // Adicionar Produto
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: _produtoSelecionado == null
                          ? ElevatedButton.icon(
                              onPressed: _selecionarProduto,
                              icon: Icon(Icons.add_shopping_cart),
                              label: Text('Adicionar Produto'),
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_produtoSelecionado!.descricao,
                                    style: TextStyle(color: Colors.white)),
                                Text(
                                  'Preço: R\$ ${_produtoSelecionado!.precoUnitario.toStringAsFixed(2)}',
                                  style: TextStyle(color: Colors.white70),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.remove, color: Colors.white),
                                      onPressed: () {
                                        if (_quantidade > 1) setState(() => _quantidade--);
                                      },
                                    ),
                                    Text('$_quantidade', style: TextStyle(color: Colors.white, fontSize: 18)),
                                    IconButton(
                                      icon: Icon(Icons.add, color: Colors.white),
                                      onPressed: () => setState(() => _quantidade++),
                                    ),
                                    SizedBox(width: 16),
                                    ElevatedButton(
                                      onPressed: () {
                                        if (_produtoSelecionado != null) {
                                          carrinho.adicionarItem(_produtoSelecionado!, _quantidade);
                                          setState(() {
                                            _produtoSelecionado = null;
                                            _quantidade = 1;
                                          });
                                        }
                                      },
                                      child: Text('Adicionar'),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.close, color: Colors.red),
                                      onPressed: () => setState(() => _produtoSelecionado = null),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Lista do Carrinho
          Expanded(
            child: carrinho.itens.isEmpty
                ? Center(child: Text('Carrinho vazio', style: TextStyle(color: Colors.white54)))
                : ListView.builder(
                    itemCount: carrinho.itens.length,
                    itemBuilder: (ctx, index) {
                      var item = carrinho.itens[index];
                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: ListTile(
                          title: Text(item.descricao, style: TextStyle(color: Colors.white)),
                          subtitle: Text(
                            'Qtd: ${item.quantidade} x R\$ ${item.precoUnitario.toStringAsFixed(2)} = R\$ ${item.subtotal.toStringAsFixed(2)}',
                            style: TextStyle(color: Colors.white70),
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => carrinho.removerItem(item.idProduto),
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Total e Finalizar
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFF1E1E1E),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: R\$ ${carrinho.total.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: carrinho.itens.isEmpty || _clienteSelecionado == null
                      ? null
                      : () => _finalizarVenda(carrinho, usuarioProvider, auth),
                  icon: Icon(Icons.check),
                  label: Text('Finalizar Venda'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF00BCD4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selecionarCliente() async {
    final clientes = await _firestore.streamClientes().first;
    if (clientes.docs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nenhum cliente cadastrado!')),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Color(0xFF1E1E1E),
        title: Text('Selecione um Cliente', style: TextStyle(color: Colors.white)),
        content: Container(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: clientes.docs.length,
            itemBuilder: (ctx, index) {
              var data = clientes.docs[index].data() as Map<String, dynamic>;
              var cliente = Cliente.fromMap(clientes.docs[index].id, data);
              return ListTile(
                title: Text(cliente.nome, style: TextStyle(color: Colors.white)),
                subtitle: Text('CPF: ${cliente.cpf}'),
                onTap: () {
                  setState(() => _clienteSelecionado = cliente);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _selecionarProduto() async {
    final produtos = await _firestore.streamProdutos().first;
    if (produtos.docs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nenhum produto cadastrado!')),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Color(0xFF1E1E1E),
        title: Text('Selecione um Produto', style: TextStyle(color: Colors.white)),
        content: Container(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: produtos.docs.length,
            itemBuilder: (ctx, index) {
              var data = produtos.docs[index].data() as Map<String, dynamic>;
              var produto = Produto.fromMap(produtos.docs[index].id, data);
              return ListTile(
                title: Text(produto.descricao, style: TextStyle(color: Colors.white)),
                subtitle: Text(
                  'Estoque: ${produto.quantidadeEstoque} | R\$ ${produto.precoUnitario.toStringAsFixed(2)}',
                ),
                onTap: () {
                  setState(() => _produtoSelecionado = produto);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _finalizarVenda(CarrinhoProvider carrinho, UsuarioProvider usuario, AuthProvider auth) async {
    try {
      final venda = Venda(
        id: '',
        idCliente: _clienteSelecionado!.id,
        idVendedor: auth.user!.uid,
        data: DateTime.now(),
        itens: List.from(carrinho.itens),
        total: carrinho.total,
      );
      await _firestore.finalizarVenda(venda);
      carrinho.limparCarrinho();
      setState(() => _clienteSelecionado = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Venda finalizada com sucesso!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
      );
    }
  }
}