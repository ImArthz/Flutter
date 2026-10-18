import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ui/viewmodels/tournament_editor_viewmodel.dart';
import 'ui/screens/start_menu_screen.dart';

void main() {
  runApp(const MetaDexApp());
}

class MetaDexApp extends StatelessWidget {
  const MetaDexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TournamentEditorViewModel()..initPlayers()),
      ],
      child: MaterialApp(
        title: 'MetaDex',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: const Color(0xFFFF7A00),
          scaffoldBackgroundColor: const Color(0xFF000000),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFFF7A00),
            secondary: Color(0xFFFFA24D),
            surface: Color(0xFF141414),
          ),
          fontFamily: 'Segoe UI', 
        ),
        home: const StartMenuScreen(),
      ),
    );
  }
}
