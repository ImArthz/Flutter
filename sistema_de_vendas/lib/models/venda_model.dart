import 'package:cloud_firestore/cloud_firestore.dart';

class ItemVenda {
  final String idProduto;
  final String descricao;
  final int quantidade;
  final double precoUnitario;
  final double subtotal;

  ItemVenda({
    required this.idProduto,
    required this.descricao,
    required this.quantidade,
    required this.precoUnitario,
    required this.subtotal,
  });

  Map<String, dynamic> toMap() {
    return {
      'idProduto': idProduto,
      'descricao': descricao,
      'quantidade': quantidade,
      'precoUnitario': precoUnitario,
      'subtotal': subtotal,
    };
  }

  factory ItemVenda.fromMap(Map<String, dynamic> map) {
    return ItemVenda(
      idProduto: map['idProduto'] ?? '',
      descricao: map['descricao'] ?? '',
      quantidade: map['quantidade'] ?? 0,
      precoUnitario: (map['precoUnitario'] ?? 0).toDouble(),
      subtotal: (map['subtotal'] ?? 0).toDouble(),
    );
  }
}

class Venda {
  final String id;
  final String idCliente;
  final String idVendedor;
  final DateTime data;
  final List<ItemVenda> itens;
  final double total;
  final String status; // 'finalizada', 'cancelada'

  Venda({
    required this.id,
    required this.idCliente,
    required this.idVendedor,
    required this.data,
    required this.itens,
    required this.total,
    this.status = 'finalizada',
  });

  Map<String, dynamic> toMap() {
    return {
      'idCliente': idCliente,
      'idVendedor': idVendedor,
      'data': Timestamp.fromDate(data),
      'itens': itens.map((i) => i.toMap()).toList(),
      'total': total,
      'status': status,
    };
  }

  factory Venda.fromMap(String id, Map<String, dynamic> map) {
    return Venda(
      id: id,
      idCliente: map['idCliente'] ?? '',
      idVendedor: map['idVendedor'] ?? '',
      data: (map['data'] as Timestamp).toDate(),
      itens: (map['itens'] as List).map((i) => ItemVenda.fromMap(i)).toList(),
      total: (map['total'] ?? 0).toDouble(),
      status: map['status'] ?? 'finalizada',
    );
  }
}