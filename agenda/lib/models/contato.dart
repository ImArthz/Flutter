class Contato {
  String id;
  String nome;
  String telefone;
  String endereco;
  String fotoPerfil;
  String observacao;

  Contato({
    required this.id,
    required this.nome,
    required this.telefone,
    required this.endereco,
    required this.fotoPerfil,
    required this.observacao,
  });

  factory Contato.fromJson(Map<String, dynamic> json) {
    return Contato(
      id: json['id'].toString(),
      nome: json['nome'] ?? '',
      telefone: json['telefone'] ?? '',
      endereco: json['endereco'] ?? '',
      fotoPerfil: json['fotoPerfil'] ?? '',
      observacao: json['observacao'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'telefone': telefone,
      'endereco': endereco,
      'fotoPerfil': fotoPerfil,
      'observacao': observacao,
    };
  }
}