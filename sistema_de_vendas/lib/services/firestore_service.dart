import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cliente_model.dart';
import '../models/produto_model.dart';
import '../models/venda_model.dart';
import '../models/usuario_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // -------------------- USUÁRIOS --------------------
  Future<void> adicionarUsuario(String uid, Usuario usuario) async {
    await _firestore.collection('usuarios').doc(uid).set(usuario.toMap());
  }

  Future<Usuario?> getUsuario(String uid) async {
    DocumentSnapshot doc = await _firestore.collection('usuarios').doc(uid).get();
    if (doc.exists) {
      return Usuario.fromMap(uid, doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Stream<QuerySnapshot> streamUsuarios() {
    return _firestore.collection('usuarios').snapshots();
  }

  Future<void> atualizarUsuario(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('usuarios').doc(uid).update(data);
  }

  // -------------------- CLIENTES --------------------
  Future<void> adicionarCliente(Cliente cliente) async {
    await _firestore.collection('clientes').add(cliente.toMap());
  }

  Stream<QuerySnapshot> streamClientes() {
    return _firestore.collection('clientes').snapshots();
  }

  Future<void> atualizarCliente(String id, Map<String, dynamic> data) async {
    await _firestore.collection('clientes').doc(id).update(data);
  }

  Future<void> deletarCliente(String id) async {
    await _firestore.collection('clientes').doc(id).delete();
  }

  // -------------------- PRODUTOS --------------------
  Future<void> adicionarProduto(Produto produto) async {
    await _firestore.collection('produtos').add(produto.toMap());
  }

  Stream<QuerySnapshot> streamProdutos() {
    return _firestore.collection('produtos').snapshots();
  }

  Future<void> atualizarProduto(String id, Map<String, dynamic> data) async {
    await _firestore.collection('produtos').doc(id).update(data);
  }

  Future<void> deletarProduto(String id) async {
    await _firestore.collection('produtos').doc(id).delete();
  }

  Future<Produto?> getProduto(String id) async {
    DocumentSnapshot doc = await _firestore.collection('produtos').doc(id).get();
    if (doc.exists) {
      return Produto.fromMap(id, doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<void> finalizarVenda(Venda venda) async {
  try {
    print('🟢 Iniciando finalização da venda (batch)...');

    // Verifica se os itens têm IDs válidos
    for (var item in venda.itens) {
      if (item.idProduto.isEmpty) {
        throw Exception('ID do produto vazio para ${item.descricao}');
      }
    }

    // Usando WriteBatch em vez de transação para evitar possíveis problemas de concorrência
    WriteBatch batch = _firestore.batch();

    // 1. Salvar a venda
    DocumentReference vendaRef = _firestore.collection('vendas').doc();
    batch.set(vendaRef, venda.toMap());

    // 2. Atualizar estoque
    for (var item in venda.itens) {
      DocumentReference prodRef = _firestore.collection('produtos').doc(item.idProduto);
      DocumentSnapshot prodSnap = await prodRef.get();
      if (!prodSnap.exists) {
        throw Exception('Produto não encontrado: ${item.descricao}');
      }
      int estoqueAtual = prodSnap.get('quantidadeEstoque') ?? 0;
      if (estoqueAtual < item.quantidade) {
        throw Exception('Estoque insuficiente para ${item.descricao} (disponível: $estoqueAtual, necessário: ${item.quantidade})');
      }
      int novoEstoque = estoqueAtual - item.quantidade;
      batch.update(prodRef, {
        'quantidadeEstoque': novoEstoque,
      });
    }

    // Executa o batch
    await batch.commit();
    print('✅ Venda finalizada com sucesso!');
  } catch (e) {
    print('❌ ERRO NA FINALIZAÇÃO: $e');
    if (e is FirebaseException) {
      print('Código do erro: ${e.code}');
      print('Mensagem: ${e.message}');
    }
    rethrow;
  }
}
}