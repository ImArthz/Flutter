import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../tree_viewer/tree_viewer_screen.dart';

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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: AppColors.primary,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.code),
              title: const Text('Repositório no GitHub'),
              onTap: () {
                launchUrl(Uri.parse('https://github.com/ImArthz/Flutter'));
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('Artigo Científico (PT-BR)'),
              onTap: () {
                launchUrl(Uri.parse('https://github.com/ImArthz/Flutter/releases/latest/download/artigo_arvores.pdf'));
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('Scientific Article (EN)'),
              onTap: () {
                launchUrl(Uri.parse('https://github.com/ImArthz/Flutter/releases/latest/download/article_trees.pdf'));
              },
            ),
          ],
        ),
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
                    childAspectRatio: 0.75,
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
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TreeViewerScreen(structure: structure),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                structure.subtitle,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
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
                        fontSize: 11,
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
