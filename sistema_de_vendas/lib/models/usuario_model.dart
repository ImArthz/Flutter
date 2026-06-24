class Usuario {
  final String uid;
  final String nome;
  final String email;
  final String nivel; // 'A', 'B', 'gerente'
  final bool ativo;

  Usuario({
    required this.uid,
    required this.nome,
    required this.email,
    required this.nivel,
    this.ativo = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'email': email,
      'nivel': nivel,
      'ativo': ativo,
    };
  }

  factory Usuario.fromMap(String uid, Map<String, dynamic> map) {
    return Usuario(
      uid: uid,
      nome: map['nome'] ?? '',
      email: map['email'] ?? '',
      nivel: map['nivel'] ?? 'B',
      ativo: map['ativo'] ?? true,
    );
  }
}