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
import '../widgets/drawer_widget.dart';

class VendasScreen extends StatefulWidget {
  @override
  _VendasScreenState createState() => _VendasScreenState();
}

class _VendasScreenState extends State<VendasScreen> {
  final FirestoreService _firestore = FirestoreService();
  Cliente? _clienteSelecionado;
  Produto? _produtoSelecionado;
  int _quantidade = 1;
  bool _isFinalizando = false;

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
    final carrinho = Provider.of<CarrinhoProvider>(context);
    final usuarioProvider = Provider.of<UsuarioProvider>(context);
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: backgroundDark,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        title: Row(
          children: [
            Icon(Icons.shopping_cart, color: successGreen),
            const SizedBox(width: 10),
            Text(
              'Nova Venda',
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
              icon: Icon(Icons.clear_all, color: errorRed),
              tooltip: 'Limpar carrinho',
              onPressed: () {
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
                        Text('Limpar carrinho', style: TextStyle(color: textLight)),
                      ],
                    ),
                    content: Text(
                      'Deseja realmente limpar todos os itens do carrinho?',
                      style: TextStyle(color: textLight.withOpacity(0.8)),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Cancelar', style: TextStyle(color: secondaryPastel)),
                      ),
                      TextButton(
                        onPressed: () {
                          carrinho.limparCarrinho();
                          Navigator.pop(context);
                        },
                        child: Text('Limpar', style: TextStyle(color: errorRed, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      drawer: DrawerWidget(),
      body: SingleChildScrollView( // ENVOLVE TUDO COM SCROLL
        child: Column(
          children: [
            // Selecionar Cliente
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [cardColor, cardColor.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: primaryPastel.withOpacity(0.2), width: 1),
                  boxShadow: [
                    BoxShadow(color: primaryPastel.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.person, color: primaryPastel, size: 20),
                          const SizedBox(width: 8),
                          Text('Cliente', style: TextStyle(color: textLight.withOpacity(0.7), fontWeight: FontWeight.w500)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _clienteSelecionado == null
                          ? Container(
                              width: double.infinity,
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [primaryPastel.withOpacity(0.2), secondaryPastel.withOpacity(0.1)],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: primaryPastel.withOpacity(0.3)),
                              ),
                              child: ElevatedButton.icon(
                                onPressed: _isFinalizando ? null : _selecionarCliente,
                                icon: Icon(Icons.person_add, color: primaryPastel),
                                label: Text('Selecionar Cliente', style: TextStyle(color: primaryPastel)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                color: primaryPastel.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: primaryPastel.withOpacity(0.3)),
                              ),
                              child: ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: primaryPastel.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(Icons.person, color: primaryPastel, size: 24),
                                ),
                                title: Text(_clienteSelecionado!.nome, style: TextStyle(color: textLight, fontWeight: FontWeight.w600)),
                                subtitle: Text('CPF: ${_clienteSelecionado!.cpf}', style: TextStyle(color: textLight.withOpacity(0.6))),
                                trailing: Container(
                                  decoration: BoxDecoration(
                                    color: errorRed.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: IconButton(
                                    icon: Icon(Icons.close, color: errorRed, size: 20),
                                    onPressed: _isFinalizando ? null : () => setState(() => _clienteSelecionado = null),
                                  ),
                                ),
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
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [cardColor, cardColor.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: accentPastel.withOpacity(0.2), width: 1),
                  boxShadow: [
                    BoxShadow(color: accentPastel.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _produtoSelecionado == null
                      ? Container(
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [accentPastel.withOpacity(0.2), accentPastel.withOpacity(0.1)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: accentPastel.withOpacity(0.3)),
                          ),
                          child: ElevatedButton.icon(
                            onPressed: _isFinalizando ? null : _selecionarProduto,
                            icon: Icon(Icons.add_shopping_cart, color: accentPastel),
                            label: Text('Adicionar Produto', style: TextStyle(color: accentPastel)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: accentPastel.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(Icons.shopping_bag, color: accentPastel, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(_produtoSelecionado!.descricao,
                                          style: TextStyle(color: textLight, fontWeight: FontWeight.w600)),
                                      Text('R\$ ${_produtoSelecionado!.precoUnitario.toStringAsFixed(2)}',
                                          style: TextStyle(color: accentPastel, fontWeight: FontWeight.w500)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Controles de quantidade
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              alignment: WrapAlignment.center,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: primaryPastel.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: IconButton(
                                    icon: Icon(Icons.remove, color: primaryPastel),
                                    onPressed: _isFinalizando
                                        ? null
                                        : () {
                                            if (_quantidade > 1) setState(() => _quantidade--);
                                          },
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: cardColor,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: primaryPastel.withOpacity(0.3)),
                                  ),
                                  child: Text('$_quantidade',
                                      style: TextStyle(color: textLight, fontSize: 18, fontWeight: FontWeight.bold)),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: primaryPastel.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: IconButton(
                                    icon: Icon(Icons.add, color: primaryPastel),
                                    onPressed: _isFinalizando ? null : () => setState(() => _quantidade++),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(colors: [successGreen, secondaryPastel]),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(color: successGreen.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2)),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: _isFinalizando
                                        ? null
                                        : () {
                                            if (_produtoSelecionado != null) {
                                              carrinho.adicionarItem(_produtoSelecionado!, _quantidade);
                                              setState(() {
                                                _produtoSelecionado = null;
                                                _quantidade = 1;
                                              });
                                            }
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    child: Text('Adicionar',
                                        style: TextStyle(color: backgroundDark, fontWeight: FontWeight.w600)),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: errorRed.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: IconButton(
                                    icon: Icon(Icons.close, color: errorRed, size: 20),
                                    onPressed: _isFinalizando ? null : () => setState(() => _produtoSelecionado = null),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                ),
              ),
            ),

            // Lista do Carrinho
            if (carrinho.itens.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.shopping_cart_outlined, color: textLight.withOpacity(0.3), size: 64),
                    const SizedBox(height: 16),
                    Text('Carrinho vazio', style: TextStyle(color: textLight.withOpacity(0.5), fontSize: 18)),
                    const SizedBox(height: 8),
                    Text('Adicione produtos para começar',
                        style: TextStyle(color: accentPastel.withOpacity(0.5), fontSize: 14)),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: carrinho.itens.length,
                itemBuilder: (ctx, index) {
                  var item = carrinho.itens[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [cardColor, cardColor.withOpacity(0.8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: primaryPastel.withOpacity(0.2), width: 1),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: accentPastel.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.shopping_bag, color: accentPastel, size: 20),
                      ),
                      title: Text(item.descricao,
                          style: TextStyle(color: textLight, fontWeight: FontWeight.w600)),
                      subtitle: Text(
                        '${item.quantidade}x R\$ ${item.precoUnitario.toStringAsFixed(2)} = R\$ ${item.subtotal.toStringAsFixed(2)}',
                        style: TextStyle(color: textLight.withOpacity(0.6), fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Container(
                        decoration: BoxDecoration(
                          color: errorRed.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.delete_outline, color: errorRed, size: 20),
                          onPressed: _isFinalizando ? null : () => carrinho.removerItem(item.idProduto),
                        ),
                      ),
                    ),
                  );
                },
              ),

            // Total e Finalizar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [cardColor, cardColor.withOpacity(0.95)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                border: Border(top: BorderSide(color: primaryPastel.withOpacity(0.3), width: 1)),
                boxShadow: [
                  BoxShadow(color: primaryPastel.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, -5)),
                ],
              ),
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Total', style: TextStyle(color: textLight.withOpacity(0.7), fontSize: 12)),
                        const SizedBox(height: 4),
                        Text('R\$ ${carrinho.total.toStringAsFixed(2)}',
                            style: TextStyle(color: successGreen, fontSize: 24, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [successGreen, secondaryPastel]),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: successGreen.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5)),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: (carrinho.itens.isEmpty || _clienteSelecionado == null || _isFinalizando)
                            ? null
                            : () => _finalizarVenda(carrinho, usuarioProvider, auth),
                        icon: _isFinalizando
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: backgroundDark),
                              )
                            : Icon(Icons.check_circle, color: backgroundDark),
                        label: Text(
                          _isFinalizando ? 'Finalizando...' : 'Finalizar Venda',
                          style: TextStyle(color: backgroundDark, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selecionarCliente() async {
    final clientes = await _firestore.streamClientes().first;
    if (clientes.docs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Nenhum cliente cadastrado!', style: TextStyle(color: Colors.white, fontSize: 14)),
          backgroundColor: accentPastel.withOpacity(0.9),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
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
              decoration: BoxDecoration(color: primaryPastel.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
              child: Icon(Icons.people, color: primaryPastel, size: 22),
            ),
            const SizedBox(width: 12),
            Text('Selecione um Cliente', style: TextStyle(color: textLight, fontWeight: FontWeight.w600)),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.5),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: clientes.docs.length,
            itemBuilder: (ctx, index) {
              var data = clientes.docs[index].data() as Map<String, dynamic>;
              var cliente = Cliente.fromMap(clientes.docs[index].id, data);
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: primaryPastel.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: primaryPastel.withOpacity(0.2)),
                ),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: primaryPastel.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                    child: Icon(Icons.person, color: primaryPastel, size: 20),
                  ),
                  title: Text(cliente.nome, style: TextStyle(color: textLight, fontWeight: FontWeight.w500)),
                  subtitle: Text('CPF: ${cliente.cpf}', style: TextStyle(color: textLight.withOpacity(0.6))),
                  trailing: Icon(Icons.arrow_forward_ios, color: primaryPastel, size: 16),
                  onTap: () {
                    setState(() => _clienteSelecionado = cliente);
                    Navigator.pop(context);
                  },
                ),
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
        SnackBar(
          content: Text('Nenhum produto cadastrado!', style: TextStyle(color: Colors.white, fontSize: 14)),
          backgroundColor: accentPastel.withOpacity(0.9),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: accentPastel.withOpacity(0.3), width: 1),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: accentPastel.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
              child: Icon(Icons.inventory_2, color: accentPastel, size: 22),
            ),
            const SizedBox(width: 12),
            Text('Selecione um Produto', style: TextStyle(color: textLight, fontWeight: FontWeight.w600)),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.5),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: produtos.docs.length,
            itemBuilder: (ctx, index) {
              var data = produtos.docs[index].data() as Map<String, dynamic>;
              var produto = Produto.fromMap(produtos.docs[index].id, data);
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: accentPastel.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: accentPastel.withOpacity(0.2)),
                ),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: accentPastel.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                    child: Icon(Icons.shopping_bag, color: accentPastel, size: 20),
                  ),
                  title: Text(produto.descricao, style: TextStyle(color: textLight, fontWeight: FontWeight.w500)),
                  subtitle: Text(
                    'Estoque: ${produto.quantidadeEstoque} | R\$ ${produto.precoUnitario.toStringAsFixed(2)}',
                    style: TextStyle(color: textLight.withOpacity(0.6)),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, color: accentPastel, size: 16),
                  onTap: () {
                    setState(() => _produtoSelecionado = produto);
                    Navigator.pop(context);
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _finalizarVenda(
    CarrinhoProvider carrinho,
    UsuarioProvider usuario,
    AuthProvider auth,
  ) async {
    if (_clienteSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Selecione um cliente!', style: TextStyle(color: Colors.white, fontSize: 14)),
          backgroundColor: errorRed.withOpacity(0.9),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    if (carrinho.itens.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Carrinho vazio!', style: TextStyle(color: Colors.white, fontSize: 14)),
          backgroundColor: errorRed.withOpacity(0.9),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() => _isFinalizando = true);

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
        SnackBar(
          content: Text('Venda finalizada com sucesso!', style: TextStyle(color: Colors.white, fontSize: 14)),
          backgroundColor: successGreen.withOpacity(0.9),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      String mensagem = e.toString();
      if (mensagem.contains('permission-denied')) {
        mensagem = 'Erro de permissão. Verifique as regras do Firestore.';
      } else if (mensagem.contains('Estoque insuficiente')) {
        mensagem = mensagem.replaceFirst('Exception: ', '');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: $mensagem', style: TextStyle(color: Colors.white, fontSize: 14)),
          backgroundColor: errorRed.withOpacity(0.9),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 6),
        ),
      );
    } finally {
      setState(() => _isFinalizando = false);
    }
  }
}