import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<User?> login(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      String mensagem = _tratarErroAuth(e.code);
      throw Exception(mensagem);
    } catch (e) {
      throw Exception('Erro inesperado. Tente novamente.');
    }
  }

  String _tratarErroAuth(String code) {
    switch (code) {
      case 'invalid-email':
        return 'E-mail inválido. Verifique o formato.';
      case 'user-not-found':
        return 'Usuário não encontrado. Verifique o e-mail.';
      case 'wrong-password':
        return 'Senha incorreta. Tente novamente.';
      case 'too-many-requests':
        return 'Muitas tentativas. Aguarde um momento.';
      case 'user-disabled':
        return 'Esta conta foi desativada.';
      case 'network-request-failed':
        return 'Erro de rede. Verifique sua conexão.';
      default:
        return 'Erro ao fazer login: $code';
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}