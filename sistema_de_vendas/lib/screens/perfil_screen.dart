import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/auth_provider.dart';
import '../providers/usuario_provider.dart';
import '../services/image_service.dart';
import '../services/firestore_service.dart';
import 'login_screen.dart';
import 'dart:convert';

class PerfilScreen extends StatefulWidget {
  @override
  _PerfilScreenState createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final ImageService _imageService = ImageService();
  final FirestoreService _firestore = FirestoreService();
  bool _isLoading = false;

  static const Color primaryPastel = Color(0xFFB8A9C9);
  static const Color backgroundDark = Color(0xFF2D2B3D);
  static const Color cardColor = Color(0xFF3D3B4F);
  static const Color textLight = Color(0xFFF0E6FF);
  static const Color successGreen = Color(0xFFB8E6C8);
  static const Color errorRed = Color(0xFFFFB8B8);
  static const Color secondaryPastel = Color(0xFFC9E4E7);

  Future<void> _atualizarFoto() async {
    final usuario = Provider.of<UsuarioProvider>(context, listen: false).usuarioLogado;
    if (usuario == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: textLight.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 20),
              Text('Foto de Perfil', style: TextStyle(color: textLight, fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(color: primaryPastel.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                  child: Icon(Icons.photo_library, color: primaryPastel),
                ),
                title: Text('Galeria', style: TextStyle(color: textLight)),
                onTap: () async {
                  Navigator.pop(context);
                  final imagem = await _imageService.pickFromGallery();
                  if (imagem != null) await _salvarFoto(usuario.uid, imagem);
                },
              ),
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(color: primaryPastel.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                  child: Icon(Icons.camera_alt, color: primaryPastel),
                ),
                title: Text('Câmera', style: TextStyle(color: textLight)),
                onTap: () async {
                  Navigator.pop(context);
                  final imagem = await _imageService.pickFromCamera();
                  if (imagem != null) await _salvarFoto(usuario.uid, imagem);
                },
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _salvarFoto(String uid, XFile imagem) async {
    setState(() => _isLoading = true);
    try {
      String? base64 = await _imageService.imageToBase64(imagem);
      if (base64 != null) {
        await _firestore.atualizarFotoBase64(uid, base64);
        Provider.of<UsuarioProvider>(context, listen: false).carregarUsuario(uid);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Foto atualizada!'), backgroundColor: successGreen, behavior: SnackBarBehavior.floating),
        );
      } else {
        _showError('Não foi possível processar a imagem.');
      }
    } catch (e) {
      _showError('Erro ao salvar foto: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg, style: TextStyle(color: Colors.white, fontSize: 14)),
        backgroundColor: errorRed.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final usuario = Provider.of<UsuarioProvider>(context).usuarioLogado;
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: backgroundDark,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        title: Text('Meu Perfil', style: TextStyle(color: textLight)),
      ),
      body: usuario == null
          ? Center(child: CircularProgressIndicator(color: primaryPastel))
          : Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    SizedBox(height: 40),
                    GestureDetector(
                      onTap: _atualizarFoto,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 70,
                            backgroundColor: primaryPastel.withOpacity(0.3),
                            backgroundImage: usuario.fotoBase64 != null && usuario.fotoBase64!.isNotEmpty
                                ? MemoryImage(base64Decode(usuario.fotoBase64!))  // <-- aqui usa base64
                                : null,
                            child: usuario.fotoBase64 == null || usuario.fotoBase64!.isEmpty
                                ? Icon(Icons.person, size: 60, color: primaryPastel)
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [primaryPastel, secondaryPastel]),
                                shape: BoxShape.circle,
                                boxShadow: [BoxShadow(color: primaryPastel.withOpacity(0.3), blurRadius: 8)],
                              ),
                              child: Icon(Icons.camera_alt, color: backgroundDark, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),
                    Text(usuario.nome, style: TextStyle(color: textLight, fontSize: 24, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(color: primaryPastel.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                      child: Text(usuario.email, style: TextStyle(color: textLight.withOpacity(0.7))),
                    ),
                    SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(color: primaryPastel.withOpacity(0.2), borderRadius: BorderRadius.circular(12), border: Border.all(color: primaryPastel.withOpacity(0.3))),
                      child: Text('Nível: ${usuario.nivel.toUpperCase()}', style: TextStyle(color: primaryPastel, fontWeight: FontWeight.w600)),
                    ),
                    SizedBox(height: 40),
                    Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: errorRed.withOpacity(0.5))),
                      child: TextButton.icon(
                        onPressed: () async {
                          await auth.logout();
                          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => LoginScreen()), (route) => false);
                        },
                        icon: Icon(Icons.logout, color: errorRed),
                        label: Text('Sair', style: TextStyle(color: errorRed, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}