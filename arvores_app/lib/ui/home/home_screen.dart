import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final structures = TreeStructure.values;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Árvores Avançadas — Visualizador'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selecione uma Estrutura',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Explore o comportamento visual de árvores especializadas passo a passo.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.3,
                  ),
                  itemCount: structures.length,
                  itemBuilder: (context, index) {
                    final structure = structures[index];
                    return _StructureCard(structure: structure);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StructureCard extends StatelessWidget {
  final TreeStructure structure;

  const _StructureCard({required this.structure});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // TODO: Navigate to TreeViewerScreen
      },
      borderRadius: BorderRadius.circular(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: structure.lightColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  structure.icon,
                  style: TextStyle(fontSize: 24, color: structure.color),
                ),
              ),
              const Spacer(),
              Text(
                structure.title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                structure.subtitle,
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  structure.avgComplexity,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
