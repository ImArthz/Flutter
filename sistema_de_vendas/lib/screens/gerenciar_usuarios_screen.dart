import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';
import '../models/usuario_model.dart';
import '../providers/usuario_provider.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/drawer_widget.dart';

class GerenciarUsuariosScreen extends StatefulWidget {
  @override
  _GerenciarUsuariosScreenState createState() => _GerenciarUsuariosScreenState();
}

class _GerenciarUsuariosScreenState extends State<GerenciarUsuariosScreen> {
  final FirestoreService _firestore = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final usuarioProvider = Provider.of<UsuarioProvider>(context);
    if (!usuarioProvider.isGerente) {
      return Scaffold(
        appBar: AppBar(title: Text('Acesso Negado')),
        drawer: DrawerWidget(),
        body: const Center(child: Text('Você não tem permissão.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Gerenciar Usuários'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _criarUsuario,
          ),
        ],
      ),
      drawer: DrawerWidget(),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.streamUsuarios(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          var docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('Nenhum usuário cadastrado.'));
          }
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (ctx, index) {
              var data = docs[index].data() as Map<String, dynamic>;
              var usuario = Usuario.fromMap(docs[index].id, data);
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(usuario.nome, style: const TextStyle(color: Colors.white)),
                  subtitle: Text('Email: ${usuario.email} | Nível: ${usuario.nivel}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _editarUsuario(usuario),
                      ),
                      IconButton(
                        icon: Icon(
                          usuario.ativo ? Icons.check_circle : Icons.cancel,
                          color: usuario.ativo ? Colors.green : Colors.red,
                        ),
                        onPressed: () async {
                          await _firestore.atualizarUsuario(usuario.uid, {
                            'ativo': !usuario.ativo,
                          });
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _criarUsuario() {
    final nomeController = TextEditingController();
    final emailController = TextEditingController();
    final senhaController = TextEditingController();
    String nivel = 'B';
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Novo Usuário', style: TextStyle(color: Colors.white)),
          content: isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomTextField(
                      controller: nomeController,
                      label: 'Nome',
                      icon: Icons.person,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: emailController,
                      label: 'E-mail',
                      icon: Icons.email,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: senhaController,
                      label: 'Senha',
                      icon: Icons.lock,
                      obscureText: true,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: nivel,
                      items: ['B', 'A', 'gerente'].map((n) {
                        return DropdownMenuItem(value: n, child: Text(n));
                      }).toList(),
                      onChanged: (v) => setStateDialog(() => nivel = v!),
                      decoration: InputDecoration(
                        labelText: 'Nível',
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: const Color(0xFF2A2A2A),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      // Validações básicas
                      if (nomeController.text.isEmpty) {
                        _showError('Digite o nome');
                        return;
                      }
                      if (emailController.text.isEmpty || !emailController.text.contains('@')) {
                        _showError('Digite um e-mail válido');
                        return;
                      }
                      if (senhaController.text.length < 6) {
                        _showError('A senha deve ter no mínimo 6 caracteres');
                        return;
                      }

                      setStateDialog(() => isLoading = true);

                      try {
                        // 1. Criar no Firebase Auth
                        final userCredential = await FirebaseAuth.instance
                            .createUserWithEmailAndPassword(
                              email: emailController.text.trim(),
                              password: senhaController.text,
                            );

                        // 2. Salvar no Firestore
                        final usuario = Usuario(
                          uid: userCredential.user!.uid,
                          nome: nomeController.text,
                          email: emailController.text.trim(),
                          nivel: nivel,
                          ativo: true,
                        );
                        await _firestore.adicionarUsuario(userCredential.user!.uid, usuario);

                        Navigator.pop(context);
                        _showSuccess('Usuário ${usuario.nome} criado com sucesso!');
                      } on FirebaseAuthException catch (e) {
                        String msg = _tratarErroAuth(e.code);
                        _showError(msg);
                        setStateDialog(() => isLoading = false);
                      } catch (e) {
                        _showError('Erro ao salvar no Firestore: $e');
                        setStateDialog(() => isLoading = false);
                      }
                    },
              child: const Text('Criar'),
            ),
          ],
        ),
      ),
    );
  }

  void _editarUsuario(Usuario usuario) {
    String novoNivel = usuario.nivel;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text('Editar Nível de ${usuario.nome}', style: const TextStyle(color: Colors.white)),
        content: DropdownButtonFormField<String>(
          value: novoNivel,
          items: ['B', 'A', 'gerente'].map((n) {
            return DropdownMenuItem(value: n, child: Text(n));
          }).toList(),
          onChanged: (v) => novoNivel = v!,
          decoration: InputDecoration(
            labelText: 'Nível',
            labelStyle: const TextStyle(color: Colors.white70),
            filled: true,
            fillColor: const Color(0xFF2A2A2A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () async {
              await _firestore.atualizarUsuario(usuario.uid, {'nivel': novoNivel});
              Navigator.pop(context);
              _showSuccess('Nível atualizado!');
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  // Helpers para mensagens
  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg, style: TextStyle(color: Colors.white)), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg, style: TextStyle(color: Colors.white)), backgroundColor: Colors.green),
    );
  }

  String _tratarErroAuth(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Este e-mail já está em uso.';
      case 'invalid-email':
        return 'E-mail inválido.';
      case 'weak-password':
        return 'Senha muito fraca. Use pelo menos 6 caracteres.';
      default:
        return 'Erro na autenticação: $code';
    }
  }
}