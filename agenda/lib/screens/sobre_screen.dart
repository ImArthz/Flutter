import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SobreScreen extends StatelessWidget {
  const SobreScreen({super.key});

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sobre'), centerTitle: true),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(
                    'https://avatars.githubusercontent.com/u/135072001?v=4'),
              ),
              const SizedBox(height: 16),
              const Text('ImArthz',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Agenda Flutter com Json Generator e Provider'),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => _launchUrl(
                    'https://github.com/ImArthz/Flutter/tree/master/agenda'),
                icon: const Icon(Icons.folder_open),
                label: const Text('Repositório do Projeto'),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => _launchUrl('https://github.com/ImArthz'),
                icon: const Icon(Icons.person),
                label: const Text('Meu GitHub'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}