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

  static const Color primaryPastel = Color(0xFFB8A9C9);
  static const Color secondaryPastel = Color(0xFFC9E4E7);
  static const Color accentPastel = Color(0xFFFFD4B8);
  static const Color backgroundDark = Color(0xFF2D2B3D);
  static const Color cardColor = Color(0xFF3D3B4F);
  static const Color textLight = Color(0xFFF0E6FF);
  static const Color successGreen = Color(0xFFB8E6C8);
  static const Color errorRed = Color(0xFFFFB8B8);

  @override
  Widget build(BuildContext context) {
    final usuarioProvider = Provider.of<UsuarioProvider>(context);
    if (!usuarioProvider.isGerente) {
      return Scaffold(
        backgroundColor: backgroundDark,
        appBar: AppBar(
          backgroundColor: cardColor,
          elevation: 0,
          title: Row(
            children: [
              Icon(Icons.lock, color: errorRed),
              const SizedBox(width: 10),
              Text('Acesso Negado', style: TextStyle(color: textLight, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        drawer: DrawerWidget(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.security, color: errorRed, size: 64),
              const SizedBox(height: 16),
              Text('Você não tem permissão.', style: TextStyle(color: textLight.withOpacity(0.7), fontSize: 18)),
              const SizedBox(height: 8),
              Text('Apenas gerentes podem acessar esta área.', style: TextStyle(color: accentPastel.withOpacity(0.6), fontSize: 14)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundDark,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        title: Row(
          children: [
            Icon(Icons.admin_panel_settings, color: primaryPastel),
            const SizedBox(width: 10),
            Text('Gerenciar Usuários', style: TextStyle(color: textLight, fontWeight: FontWeight.w600)),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: primaryPastel.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: primaryPastel.withOpacity(0.3)),
            ),
            child: IconButton(
              icon: Icon(Icons.add, color: primaryPastel),
              onPressed: _criarUsuario,
            ),
          ),
        ],
      ),
      drawer: DrawerWidget(),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.streamUsuarios(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: errorRed, size: 48),
                  const SizedBox(height: 16),
                  Text('Erro: ${snapshot.error}', style: TextStyle(color: errorRed)),
                ],
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: primaryPastel));
          }
          var docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, color: primaryPastel.withOpacity(0.5), size: 64),
                  const SizedBox(height: 16),
                  Text('Nenhum usuário cadastrado.', style: TextStyle(color: textLight.withOpacity(0.7), fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('Toque no + para adicionar', style: TextStyle(color: accentPastel.withOpacity(0.6), fontSize: 14)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (ctx, index) {
              var data = docs[index].data() as Map<String, dynamic>;
              var usuario = Usuario.fromMap(docs[index].id, data);
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [cardColor, cardColor.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: primaryPastel.withOpacity(0.2), width: 1),
                  boxShadow: [
                    BoxShadow(color: primaryPastel.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _getNivelColor(usuario.nivel).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          usuario.nivel == 'gerente' ? Icons.admin_panel_settings : Icons.person,
                          color: _getNivelColor(usuario.nivel),
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    usuario.nome,
                                    style: TextStyle(color: textLight, fontWeight: FontWeight.w600, fontSize: 16),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getNivelColor(usuario.nivel).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: _getNivelColor(usuario.nivel).withOpacity(0.3)),
                                  ),
                                  child: Text(
                                    usuario.nivel.toUpperCase(),
                                    style: TextStyle(color: _getNivelColor(usuario.nivel), fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.email, size: 14, color: secondaryPastel),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    usuario.email,
                                    style: TextStyle(color: textLight.withOpacity(0.7), fontSize: 13),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  usuario.ativo ? Icons.check_circle : Icons.cancel,
                                  size: 14,
                                  color: usuario.ativo ? successGreen : errorRed,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  usuario.ativo ? 'Ativo' : 'Inativo',
                                  style: TextStyle(color: usuario.ativo ? successGreen : errorRed, fontSize: 13, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: secondaryPastel.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              icon: Icon(Icons.edit, color: secondaryPastel, size: 20),
                              padding: const EdgeInsets.all(6),
                              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                              onPressed: () => _editarUsuario(usuario),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            decoration: BoxDecoration(
                              color: (usuario.ativo ? errorRed : successGreen).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              icon: Icon(
                                usuario.ativo ? Icons.block : Icons.check_circle,
                                color: usuario.ativo ? errorRed : successGreen,
                                size: 20,
                              ),
                              padding: const EdgeInsets.all(6),
                              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                              onPressed: () async {
                                final acao = usuario.ativo ? 'desativar' : 'ativar';
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    backgroundColor: cardColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      side: BorderSide(color: primaryPastel.withOpacity(0.3), width: 1),
                                    ),
                                    title: Row(
                                      children: [
                                        Icon(usuario.ativo ? Icons.block : Icons.check_circle, color: usuario.ativo ? errorRed : successGreen),
                                        const SizedBox(width: 10),
                                        Text('Confirmar ação', style: TextStyle(color: textLight)),
                                      ],
                                    ),
                                    content: Text(
                                      'Deseja realmente $acao ${usuario.nome}?',
                                      style: TextStyle(color: textLight.withOpacity(0.8)),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text('Cancelar', style: TextStyle(color: secondaryPastel)),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          await _firestore.atualizarUsuario(usuario.uid, {'ativo': !usuario.ativo});
                                          Navigator.pop(context);
                                          _showSuccess('Usuário ${usuario.ativo ? "desativado" : "ativado"} com sucesso!');
                                        },
                                        child: Text('Confirmar', style: TextStyle(color: usuario.ativo ? errorRed : successGreen, fontWeight: FontWeight.w600)),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
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

  Color _getNivelColor(String nivel) {
    switch (nivel) {
      case 'gerente':
        return primaryPastel;
      case 'A':
        return secondaryPastel;
      case 'B':
        return accentPastel;
      default:
        return textLight;
    }
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
          backgroundColor: cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: primaryPastel.withOpacity(0.3), width: 1),
          ),
          title: Row(
            children: [
              Icon(Icons.person_add, color: primaryPastel),
              const SizedBox(width: 10),
              Text('Novo Usuário', style: TextStyle(color: textLight, fontWeight: FontWeight.w600)),
            ],
          ),
          content: isLoading
              ? Center(child: CircularProgressIndicator(color: primaryPastel))
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomTextField(controller: nomeController, label: 'Nome', icon: Icons.person),
                    const SizedBox(height: 12),
                    CustomTextField(controller: emailController, label: 'E-mail', icon: Icons.email),
                    const SizedBox(height: 12),
                    CustomTextField(controller: senhaController, label: 'Senha', icon: Icons.lock, obscureText: true),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: nivel,
                      dropdownColor: cardColor,
                      style: TextStyle(color: textLight),
                      decoration: InputDecoration(
                        labelText: 'Nível',
                        labelStyle: TextStyle(color: textLight.withOpacity(0.7)),
                        prefixIcon: Icon(Icons.shield, color: _getNivelColor(nivel)),
                        filled: true,
                        fillColor: backgroundDark,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primaryPastel.withOpacity(0.3))),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primaryPastel.withOpacity(0.3))),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primaryPastel)),
                      ),
                      items: ['B', 'A', 'gerente'].map((n) {
                        return DropdownMenuItem(
                          value: n,
                          child: Row(
                            children: [
                              Icon(n == 'gerente' ? Icons.admin_panel_settings : Icons.person, color: _getNivelColor(n), size: 18),
                              const SizedBox(width: 8),
                              Text(n.toUpperCase(), style: TextStyle(color: _getNivelColor(n))),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (v) => setStateDialog(() => nivel = v!),
                    ),
                  ],
                ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: Text('Cancelar', style: TextStyle(color: errorRed, fontWeight: FontWeight.w500)),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (nomeController.text.isEmpty) { _showError('Digite o nome'); return; }
                      if (emailController.text.isEmpty || !emailController.text.contains('@')) { _showError('Digite um e-mail válido'); return; }
                      if (senhaController.text.length < 6) { _showError('A senha deve ter no mínimo 6 caracteres'); return; }

                      setStateDialog(() => isLoading = true);
                      try {
                        final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                          email: emailController.text.trim(),
                          password: senhaController.text,
                        );
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
                        _showError(_tratarErroAuth(e.code));
                        setStateDialog(() => isLoading = false);
                      } catch (e) {
                        _showError('Erro ao salvar no Firestore: $e');
                        setStateDialog(() => isLoading = false);
                      }
                    },
              style: ElevatedButton.styleFrom(backgroundColor: primaryPastel, foregroundColor: backgroundDark, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: Text('Criar', style: TextStyle(color: backgroundDark, fontWeight: FontWeight.w600)),
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
      builder: (_) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          backgroundColor: cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: primaryPastel.withOpacity(0.3), width: 1)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: _getNivelColor(usuario.nivel).withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                child: Icon(usuario.nivel == 'gerente' ? Icons.admin_panel_settings : Icons.person, color: _getNivelColor(usuario.nivel)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text('Editar Nível de ${usuario.nome}', style: TextStyle(color: textLight, fontWeight: FontWeight.w600, fontSize: 16)),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Email: ${usuario.email}', style: TextStyle(color: textLight.withOpacity(0.7), fontSize: 13)),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: novoNivel,
                dropdownColor: cardColor,
                style: TextStyle(color: textLight),
                decoration: InputDecoration(
                  labelText: 'Nível',
                  labelStyle: TextStyle(color: textLight.withOpacity(0.7)),
                  prefixIcon: Icon(Icons.shield, color: _getNivelColor(novoNivel)),
                  filled: true,
                  fillColor: backgroundDark,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primaryPastel.withOpacity(0.3))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primaryPastel.withOpacity(0.3))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primaryPastel)),
                ),
                items: ['B', 'A', 'gerente'].map((n) {
                  return DropdownMenuItem(
                    value: n,
                    child: Row(
                      children: [
                        Icon(n == 'gerente' ? Icons.admin_panel_settings : Icons.person, color: _getNivelColor(n), size: 18),
                        const SizedBox(width: 8),
                        Text(n.toUpperCase(), style: TextStyle(color: _getNivelColor(n))),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (v) => setStateDialog(() => novoNivel = v!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar', style: TextStyle(color: errorRed, fontWeight: FontWeight.w500)),
            ),
            ElevatedButton(
              onPressed: () async {
                await _firestore.atualizarUsuario(usuario.uid, {'nivel': novoNivel});
                Navigator.pop(context);
                _showSuccess('Nível atualizado!');
              },
              style: ElevatedButton.styleFrom(backgroundColor: primaryPastel, foregroundColor: backgroundDark, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: Text('Salvar', style: TextStyle(color: backgroundDark, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: TextStyle(color: Colors.white, fontSize: 14)),
        backgroundColor: errorRed.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: TextStyle(color: Colors.white, fontSize: 14)),
        backgroundColor: successGreen.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
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