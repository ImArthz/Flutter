import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/usuario_provider.dart';
import 'providers/carrinho_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/vendas_screen.dart';              // <-- IMPORTANTE
import 'screens/clientes_screen.dart';            // <-- IMPORTANTE
import 'screens/produtos_screen.dart';            // <-- IMPORTANTE
import 'screens/gerenciar_usuarios_screen.dart';  // <-- IMPORTANTE

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.android);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UsuarioProvider()),
        ChangeNotifierProvider(create: (_) => CarrinhoProvider()),
      ],
      child: MaterialApp(
        title: 'GameStore Vendas',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: const Color(0xFF7B2FBE),
          scaffoldBackgroundColor: const Color(0xFF121212),
          cardColor: const Color(0xFF1E1E1E),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF7B2FBE),
            secondary: Color(0xFF00BCD4),
            surface: Color(0xFF1E1E1E),
            background: Color(0xFF121212),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1E1E1E),
            elevation: 0,
            centerTitle: true,
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            iconTheme: IconThemeData(color: Colors.white),
          ),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Colors.white70),
            bodyMedium: TextStyle(color: Colors.white70),
            titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFF2A2A2A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            hintStyle: const TextStyle(color: Colors.white38),
            labelStyle: const TextStyle(color: Colors.white70),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7B2FBE),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          cardTheme: const CardThemeData(
            color: Color(0xFF1E1E1E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            elevation: 4,
          ),
        ),
        routes: {
          '/home': (context) => HomeScreen(),
          '/vendas': (context) => VendasScreen(),
          '/clientes': (context) => ClientesScreen(),
          '/produtos': (context) => ProdutosScreen(),
          '/gerenciar_usuarios': (context) => GerenciarUsuariosScreen(),
        },
        home: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            if (auth.user != null) {
              return HomeScreen();
            } else {
              return LoginScreen();
            }
          },
        ),
      ),
    );
  }
}