class Cliente {
  final String id;
  final String nome;
  final String cpf;
  final String telefone;
  final String endereco;

  Cliente({
    required this.id,
    required this.nome,
    required this.cpf,
    required this.telefone,
    required this.endereco,
  });

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'cpf': cpf,
      'telefone': telefone,
      'endereco': endereco,
    };
  }

  factory Cliente.fromMap(String id, Map<String, dynamic> map) {
    return Cliente(
      id: id,
      nome: map['nome'] ?? '',
      cpf: map['cpf'] ?? '',
      telefone: map['telefone'] ?? '',
      endereco: map['endereco'] ?? '',
    );
  }
}