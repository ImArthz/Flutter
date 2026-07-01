class Usuario {
  final String uid;
  final String nome;
  final String email;
  final String nivel;
  final bool ativo;
  final String? fotoBase64;   // <-- alterado

  Usuario({
    required this.uid,
    required this.nome,
    required this.email,
    required this.nivel,
    this.ativo = true,
    this.fotoBase64,           // <-- alterado
  });

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'email': email,
      'nivel': nivel,
      'ativo': ativo,
      'fotoBase64': fotoBase64,   // <-- alterado
    };
  }

  factory Usuario.fromMap(String uid, Map<String, dynamic> map) {
    return Usuario(
      uid: uid,
      nome: map['nome'] ?? '',
      email: map['email'] ?? '',
      nivel: map['nivel'] ?? 'B',
      ativo: map['ativo'] ?? true,
      fotoBase64: map['fotoBase64'],   // <-- alterado
    );
  }
}