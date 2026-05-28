import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/contatos_provider.dart';

class ListaContatosScreen extends StatelessWidget {
  final VoidCallback onContactSelected;
  const ListaContatosScreen({super.key, required this.onContactSelected});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ContatosProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Agenda Completa')),
      body: provider.contatos.isEmpty
          ? const Center(child: Text('Nenhum contato'))
          : ListView.builder(
              itemCount: provider.contatos.length,
              itemBuilder: (context, index) {
                final contato = provider.contatos[index];
                final selecionado = index == provider.currentIndex;

                return InkWell(
                  onTap: () {
                    provider.selectByIndex(index);
                    onContactSelected(); // volta para a aba Início
                  },
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: selecionado
                          ? Colors.blue.withOpacity(0.1)
                          : Colors.white,
                      border: Border.all(
                          color: selecionado ? Colors.blue : Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: _buildImage(contato.fotoPerfil),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                contato.nome,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 2),
                              Text(contato.telefone),
                              const SizedBox(height: 2),
                              Text(contato.endereco,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 4),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  contato.observacao,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildImage(String path) {
    ImageProvider provider;
    if (path.startsWith('http')) {
      provider = NetworkImage(path);
    } else if (path.isNotEmpty) {
      provider = FileImage(File(path));
    } else {
      provider = const AssetImage('assets/images/default_avatar.png');
    }

    return Image(
      image: provider,
      width: 50,
      height: 50,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: 50,
          height: 50,
          color: Colors.grey[300],
          child: const Icon(Icons.person, size: 30, color: Colors.white),
        );
      },
    );
  }
}