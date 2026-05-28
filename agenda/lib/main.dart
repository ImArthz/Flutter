import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'providers/contatos_provider.dart';
import 'screens/home_screen.dart';
import 'screens/criar_contato_screen.dart';
import 'screens/lista_contatos_screen.dart';
import 'screens/sobre_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ContatosProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Agenda',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const MainScreen(),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _screenIndex = 0;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _carregarContatos();
  }

  /// Carrega os contatos do arquivo local ou, se não existir, do asset
  Future<void> _carregarContatos() async {
    final provider = context.read<ContatosProvider>();

    try {
      // Tenta carregar do diretório de documentos (dados salvos)
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/contatos_salvos.json');

      if (await file.exists()) {
        final jsonString = await file.readAsString();
        final List<dynamic> jsonList = json.decode(jsonString);
        provider.loadFromJsonList(jsonList);
      } else {
        // Se não existe arquivo salvo, carrega do asset
        final assetString =
            await rootBundle.loadString('assets/data/contatos.json');
        final List<dynamic> jsonList = json.decode(assetString);
        provider.loadFromJsonList(jsonList);
      }
    } catch (e) {
      // Fallback: tenta carregar do asset mesmo se deu erro
      try {
        final assetString =
            await rootBundle.loadString('assets/data/contatos.json');
        final List<dynamic> jsonList = json.decode(assetString);
        provider.loadFromJsonList(jsonList);
      } catch (_) {
        provider.loadFromJsonList([]);
      }
    }

    // Adiciona listener para salvar automaticamente quando os dados mudarem
    provider.addListener(_salvarContatos);

    setState(() => _loaded = true);
  }

  /// Salva a lista atual no arquivo local
  Future<void> _salvarContatos() async {
    final provider = context.read<ContatosProvider>();
    final jsonList = provider.toJsonList();
    final jsonString = const JsonEncoder.withIndent('  ').convert(jsonList);

    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/contatos_salvos.json');
      await file.writeAsString(jsonString);
    } catch (e) {
      debugPrint('Erro ao salvar contatos: $e');
    }
  }

  void switchToTab(int index) {
    setState(() => _screenIndex = index);
  }

  @override
  void dispose() {
    context.read<ContatosProvider>().removeListener(_salvarContatos);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final screens = [
      HomeScreen(onDelete: () => switchToTab(0)),
      CriarContatoScreen(onSave: () => switchToTab(0)),
      ListaContatosScreen(onContactSelected: () => switchToTab(0)),
      const SobreScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda'),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text('Menu',
                  style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Início'),
              selected: _screenIndex == 0,
              onTap: () {
                switchToTab(0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text('Criar Contato'),
              selected: _screenIndex == 1,
              onTap: () {
                switchToTab(1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('Agenda Completa'),
              selected: _screenIndex == 2,
              onTap: () {
                switchToTab(2);
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Sobre'),
              selected: _screenIndex == 3,
              onTap: () {
                switchToTab(3);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: screens[_screenIndex],
    );
  }
}