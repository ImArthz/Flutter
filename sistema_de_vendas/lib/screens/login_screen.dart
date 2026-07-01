import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:local_auth/local_auth.dart'; // NOVO
import '../providers/auth_provider.dart';
import '../providers/usuario_provider.dart';
import '../widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Paleta de cores pastel gamer
  static const Color primaryPastel = Color(0xFFB8A9C9);
  static const Color secondaryPastel = Color(0xFFC9E4E7);
  static const Color accentPastel = Color(0xFFFFD4B8);
  static const Color backgroundDark = Color(0xFF2D2B3D);
  static const Color cardColor = Color(0xFF3D3B4F);
  static const Color textLight = Color(0xFFF0E6FF);
  static const Color successGreen = Color(0xFFB8E6C8);
  static const Color errorRed = Color(0xFFFFB8B8);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
          ),
        );
    _animationController.forward();
    // REMOVIDO: _verificarBiometria();
  }

  // NOVO - Verificar biometria disponível
  Future<void> _verificarBiometria() async {
    final localAuth = LocalAuthentication();
    bool podeAutenticar = await localAuth.canCheckBiometrics;
    bool temBiometria = await localAuth.isDeviceSupported();

    if (podeAutenticar && temBiometria) {
      // Se já tem usuário logado antes, tenta biometria
      _tentarLoginBiometrico();
    }
  }

  // NOVO - Login com biometria
  Future<void> _tentarLoginBiometrico() async {
    final localAuth = LocalAuthentication();
    try {
      bool autenticado = await localAuth.authenticate(
        localizedReason: 'Use sua digital para acessar o app',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (autenticado && mounted) {
        // Tenta restaurar sessão anterior
        final auth = Provider.of<AuthProvider>(context, listen: false);
        if (auth.user != null) {
          // Já está logado, só vai pra home
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    } catch (e) {
      print('Erro na biometria: $e');
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      await auth.login(_emailController.text, _senhaController.text);

      if (!mounted) return;
      final user = auth.user;
      if (user != null) {
        final usuarioProvider = Provider.of<UsuarioProvider>(
          context,
          listen: false,
        );
        usuarioProvider.carregarUsuario(user.uid);
      }
    } catch (e) {
      if (!mounted) return;
      String mensagem = e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            mensagem,
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          backgroundColor: errorRed.withOpacity(0.9),
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [backgroundDark, cardColor, backgroundDark],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        cardColor.withOpacity(0.95),
                        cardColor.withOpacity(0.8),
                      ],
                    ),
                    border: Border.all(
                      color: primaryPastel.withOpacity(0.2),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primaryPastel.withOpacity(0.15),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                      BoxShadow(
                        color: secondaryPastel.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TweenAnimationBuilder(
                            duration: const Duration(milliseconds: 800),
                            tween: Tween<double>(begin: 0.0, end: 1.0),
                            builder: (context, double value, child) {
                              return Transform.scale(
                                scale: value,
                                child: child,
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [primaryPastel, secondaryPastel],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryPastel.withOpacity(0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.sports_esports,
                                size: 48,
                                color: backgroundDark,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: [primaryPastel, secondaryPastel],
                            ).createShader(bounds),
                            child: const Text(
                              'GameStore',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Sistema de Vendas',
                            style: TextStyle(
                              color: textLight.withOpacity(0.7),
                              fontSize: 16,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 40),
                          CustomTextField(
                            controller: _emailController,
                            label: 'E-mail',
                            icon: Icons.email,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Digite o e-mail';
                              if (!value.contains('@'))
                                return 'E-mail inválido';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _senhaController,
                            label: 'Senha',
                            icon: Icons.lock,
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Digite a senha';
                              if (value.length < 6)
                                return 'Mínimo 6 caracteres';
                              return null;
                            },
                          ),
                          const SizedBox(height: 32),
                          _isLoading
                              ? Column(
                                  children: [
                                    CircularProgressIndicator(
                                      color: primaryPastel,
                                      strokeWidth: 3,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Entrando...',
                                      style: TextStyle(
                                        color: textLight.withOpacity(0.7),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                )
                              : Container(
                                  width: double.infinity,
                                  height: 55,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [primaryPastel, secondaryPastel],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: primaryPastel.withOpacity(0.3),
                                        blurRadius: 15,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: _login,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.login,
                                          color: backgroundDark,
                                          size: 24,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'ENTRAR',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: backgroundDark,
                                            letterSpacing: 2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                          const SizedBox(height: 16),
                          // NOVO - Botão de Biometria
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: primaryPastel.withOpacity(0.5),
                              ),
                            ),
                            child: TextButton.icon(
                              onPressed: _tentarLoginBiometrico,
                              icon: Icon(
                                Icons.fingerprint,
                                color: primaryPastel,
                              ),
                              label: Text(
                                'Entrar com Biometria',
                                style: TextStyle(color: primaryPastel),
                              ),
                              style: TextButton.styleFrom(
                                minimumSize: Size(double.infinity, 50),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.lock_outline,
                                color: secondaryPastel.withOpacity(0.7),
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Acesso seguro',
                                style: TextStyle(
                                  color: secondaryPastel.withOpacity(0.7),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
