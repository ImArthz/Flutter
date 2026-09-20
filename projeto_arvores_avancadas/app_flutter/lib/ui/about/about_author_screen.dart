import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';

class AboutAuthorScreen extends StatelessWidget {
  const AboutAuthorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sobre o Autor')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 20, spreadRadius: 5)
                  ],
                ),
                child: const CircleAvatar(
                  radius: 80,
                  backgroundImage: NetworkImage('https://avatars.githubusercontent.com/u/135072001?v=4'),
                  backgroundColor: AppColors.border,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Arthur de Oliveira Mendonça',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Engenharia da Computação\nCEFET-MG (Divinópolis)',
                style: TextStyle(fontSize: 18, color: AppColors.textSecondary, height: 1.4),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              const Card(
                elevation: 0,
                color: AppColors.surface,
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text(
                    'Este projeto foi desenvolvido como um trabalho prático para a disciplina de Algoritmos e Estruturas de Dados 2 (AED2), lecionada pelo professor Michel Pires da Silva.\n\n'
                    'O objetivo é consolidar o aprendizado das estruturas de dados avançadas, criando uma ferramenta interativa de visualização e analisando o desempenho assintótico e espacial de cada árvore em diferentes cenários de estresse.',
                    style: TextStyle(fontSize: 16, color: AppColors.textPrimary, height: 1.5),
                    textAlign: TextAlign.justify,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => launchUrl(Uri.parse('https://github.com/ImArthz')),
                icon: const Icon(Icons.code),
                label: const Text('Acessar meu GitHub'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
