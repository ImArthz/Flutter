class Produto {
  final String id;
  final String codigo;
  final String descricao;
  final int quantidadeEstoque;
  final double precoUnitario;

  Produto({
    required this.id,
    required this.codigo,
    required this.descricao,
    required this.quantidadeEstoque,
    required this.precoUnitario,
  });

  Map<String, dynamic> toMap() {
    return {
      'codigo': codigo,
      'descricao': descricao,
      'quantidadeEstoque': quantidadeEstoque,
      'precoUnitario': precoUnitario,
    };
  }

  factory Produto.fromMap(String id, Map<String, dynamic> map) {
    return Produto(
      id: id,
      codigo: map['codigo'] ?? '',
      descricao: map['descricao'] ?? '',
      quantidadeEstoque: map['quantidadeEstoque'] ?? 0,
      precoUnitario: (map['precoUnitario'] ?? 0).toDouble(),
    );
  }
}