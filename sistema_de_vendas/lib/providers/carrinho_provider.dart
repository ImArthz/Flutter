import 'package:flutter/material.dart';
import '../models/produto_model.dart';
import '../models/venda_model.dart';

class CarrinhoProvider extends ChangeNotifier {
  List<ItemVenda> _itens = [];

  List<ItemVenda> get itens => _itens;

  double get total {
    return _itens.fold(0, (sum, item) => sum + item.subtotal);
  }

  void adicionarItem(Produto produto, int quantidade) {
    if (quantidade <= 0) return;
    // Verifica se o item já existe no carrinho
    int index = _itens.indexWhere((i) => i.idProduto == produto.id);
    if (index != -1) {
      // Atualiza quantidade
      int novaQtd = _itens[index].quantidade + quantidade;
      _itens[index] = ItemVenda(
        idProduto: produto.id,
        descricao: produto.descricao,
        quantidade: novaQtd,
        precoUnitario: produto.precoUnitario,
        subtotal: novaQtd * produto.precoUnitario,
      );
    } else {
      _itens.add(ItemVenda(
        idProduto: produto.id,
        descricao: produto.descricao,
        quantidade: quantidade,
        precoUnitario: produto.precoUnitario,
        subtotal: quantidade * produto.precoUnitario,
      ));
    }
    notifyListeners();
  }

  void removerItem(String idProduto) {
    _itens.removeWhere((i) => i.idProduto == idProduto);
    notifyListeners();
  }

  void limparCarrinho() {
    _itens.clear();
    notifyListeners();
  }

  void atualizarQuantidade(String idProduto, int novaQuantidade) {
    int index = _itens.indexWhere((i) => i.idProduto == idProduto);
    if (index != -1) {
      if (novaQuantidade <= 0) {
        _itens.removeAt(index);
      } else {
        var item = _itens[index];
        _itens[index] = ItemVenda(
          idProduto: item.idProduto,
          descricao: item.descricao,
          quantidade: novaQuantidade,
          precoUnitario: item.precoUnitario,
          subtotal: novaQuantidade * item.precoUnitario,
        );
      }
      notifyListeners();
    }
  }
}