import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../tree_viewer/tree_viewer_screen.dart';
import '../benchmark/benchmark_screen.dart';
import '../about/about_author_screen.dart';
import '../about/tree_theory_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final structures = TreeStructure.values;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Árvores Avançadas', style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 60, bottom: 20),
              decoration: const BoxDecoration(color: AppColors.primary),
              child: const Column(
                children: [
                  Icon(Icons.park, size: 64, color: Colors.white),
                  SizedBox(height: 12),
                  Text('Árvores Avançadas', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  Text('Visualizador e Simulador', style: TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ListTile(
                    leading: const Icon(Icons.school, color: AppColors.primary),
                    title: const Text('Sobre o Autor', style: TextStyle(fontWeight: FontWeight.w500)),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutAuthorScreen()));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.menu_book, color: AppColors.secondary),
                    title: const Text('Teoria das Árvores', style: TextStyle(fontWeight: FontWeight.w500)),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const TreeTheoryScreen()));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.speed, color: AppColors.error),
                    title: const Text('Benchmarking', style: TextStyle(fontWeight: FontWeight.w500)),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const BenchmarkScreen()));
                    },
                  ),
                  const Divider(),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text('Recursos Acadêmicos', style: TextStyle(color: AppColors.textDisabled, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                  ListTile(
                    leading: const Icon(Icons.picture_as_pdf, color: Colors.redAccent),
                    title: const Text('Artigo Científico (PT-BR)'),
                    onTap: () => launchUrl(Uri.parse('https://github.com/ImArthz/Flutter/releases/latest/download/artigo_arvores.pdf')),
                  ),
                  ListTile(
                    leading: const Icon(Icons.picture_as_pdf, color: Colors.redAccent),
                    title: const Text('Scientific Article (EN)'),
                    onTap: () => launchUrl(Uri.parse('https://github.com/ImArthz/Flutter/releases/latest/download/article_trees.pdf')),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Container(
        color: AppColors.background,
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.75, // Ajustado para evitar overflow
          ),
          itemCount: structures.length,
          itemBuilder: (context, index) {
            final struct = structures[index];
            return Card(
              color: AppColors.surface,
              elevation: 4,
              shadowColor: struct.color.withOpacity(0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: struct.color.withOpacity(0.3), width: 1.5),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TreeViewerScreen(structure: struct),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.account_tree, size: 48, color: struct.color),
                      const SizedBox(height: 16),
                      Text(
                        struct.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        struct.subtitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: struct.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: struct.color.withOpacity(0.5)),
                        ),
                        child: Text(
                          struct.avgComplexity,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: struct.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
