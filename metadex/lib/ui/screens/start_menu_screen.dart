import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/tournament_editor_viewmodel.dart';
import 'tournament_editor_screen.dart';

class StartMenuScreen extends StatelessWidget {
  const StartMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TournamentEditorViewModel>();
    final topArq = viewModel.metagame.isNotEmpty ? viewModel.metagame.first.deckName : 'Charizard ex';

    return Scaffold(
      backgroundColor: const Color(0xFF060606),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 820),
            padding: const EdgeInsets.all(36),
            decoration: BoxDecoration(
              color: const Color(0xFF121212),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFFF7A00), width: 2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x28FF7A00),
                  blurRadius: 80,
                  spreadRadius: 8,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.analytics_outlined, size: 68, color: Color(0xFFFF7A00)),
                const SizedBox(height: 16),
                const Text(
                  'METADEX',
                  style: TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 8,
                    color: Colors.white,
                  ),
                ),
                const Text(
                  'Tournament Reporting & Metagame Analytics • Pokémon TCG',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFFFFA24D),
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F160A),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF4A2C0A)),
                  ),
                  child: Text(
                    'Meta da Semana (${viewModel.storeCity}-${viewModel.storeUf}): Líder $topArq • Formato ${viewModel.formato.nome}',
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ),
                const SizedBox(height: 28),
                const Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: [
                    _PersonaFeatureCard(
                      icon: Icons.storefront,
                      persona: 'Roberto (Lojista)',
                      feature: 'Import .TDF do TOM + PDF e Cards Sociais em 1 clique',
                    ),
                    _PersonaFeatureCard(
                      icon: Icons.gavel,
                      persona: 'Ana (Juíza / Professor)',
                      feature: 'Validador 60 Cartas/ACE SPEC + Curadoria de Arquétipos',
                    ),
                    _PersonaFeatureCard(
                      icon: Icons.query_stats,
                      persona: 'Lucas (Grinder)',
                      feature: 'Conversão Top Cut, Matriz de Matchups & WR Bayesiano',
                    ),
                    _PersonaFeatureCard(
                      icon: Icons.auto_awesome,
                      persona: 'Marina (Iniciante)',
                      feature: '% Presença de Cartas + Lista Consenso (Core/Tech)',
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF7A00),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const TournamentEditorScreen()),
                      );
                    },
                    icon: const Icon(Icons.rocket_launch),
                    label: const Text(
                      'CRIAR NOVO RELATÓRIO',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Projeto de fã não oficial • Conformidade LGPD (Art. 14) & Proteção Anti-Scouting (Embargo RN-03)',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: Colors.white38),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PersonaFeatureCard extends StatelessWidget {
  final IconData icon;
  final String persona;
  final String feature;

  const _PersonaFeatureCard({
    required this.icon,
    required this.persona,
    required this.feature,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 340,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2D2D2D)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFFF7A00), size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  persona,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  feature,
                  style: const TextStyle(fontSize: 11, color: Colors.white60),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
