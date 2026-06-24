import 'package:flutter/material.dart';
import '../models/usuario_model.dart';
import '../services/firestore_service.dart';
import 'auth_provider.dart';

class UsuarioProvider extends ChangeNotifier {
  final FirestoreService _firestore = FirestoreService();
  Usuario? _usuarioLogado;

  Usuario? get usuarioLogado => _usuarioLogado;

  void carregarUsuario(String uid) async {
    Usuario? user = await _firestore.getUsuario(uid);
    if (user != null) {
      _usuarioLogado = user;
      notifyListeners();
    }
  }

  // Verifica se pode cadastrar produtos (nível A ou gerente)
  bool get podeCadastrarProdutos {
    if (_usuarioLogado == null) return false;
    return _usuarioLogado!.nivel == 'A' || _usuarioLogado!.nivel == 'gerente';
  }

  // Verifica se é gerente
  bool get isGerente {
    return _usuarioLogado?.nivel == 'gerente';
  }
}