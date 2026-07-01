import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/contatos_provider.dart';
import 'editar_contato_screen.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onDelete;
  const HomeScreen({super.key, required this.onDelete});

  void _confirmDelete(BuildContext context) {
    final provider = context.read<ContatosProvider>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir contato'),
        content: const Text('Tem certeza que deseja excluir este contato?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              provider.deleteCurrent();
              Navigator.pop(ctx);
              onDelete(); // volta para a aba Início
              // Recarrega do arquivo para garantir consistência
              provider.reloadFromLocalFile();
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _editar(BuildContext context, int index) async {
    // Aguarda o retorno da tela de edição
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditarContatoScreen(index: index),
      ),
    );
    // Após editar (ou mesmo se voltar sem salvar), recarrega do disco
    final provider = context.read<ContatosProvider>();
    provider.reloadFromLocalFile();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ContatosProvider>();
    if (provider.contatos.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Contato'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Recarregar',
              onPressed: () => provider.reloadFromLocalFile(),
            ),
          ],
        ),
        body: const Center(child: Text('Nenhum contato cadastrado.')),
      );
    }

    final contato = provider.currentContato;
    final currentIdx = provider.currentIndex;

    return Scaffold(
      key: ValueKey(currentIdx), // força reconstrução se o índice mudar
      appBar: AppBar(
        title: const Text('Contato'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Recarregar',
            onPressed: () => provider.reloadFromLocalFile(),
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Editar',
            onPressed: () => _editar(context, currentIdx),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Excluir',
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Foto de perfil com fallback
            _buildProfileImage(contato.fotoPerfil, contato.id),
            const SizedBox(height: 20),
            // Campos com key única para forçar recriação ao mudar de contato
            TextFormField(
              key: ValueKey('nome_${contato.id}'),
              initialValue: contato.nome,
              readOnly: true,
              decoration: const InputDecoration(
                  labelText: 'Nome', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: ValueKey('tel_${contato.id}'),
              initialValue: contato.telefone,
              readOnly: true,
              decoration: const InputDecoration(
                  labelText: 'Telefone', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: ValueKey('end_${contato.id}'),
              initialValue: contato.endereco,
              readOnly: true,
              decoration: const InputDecoration(
                  labelText: 'Endereço', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: ValueKey('obs_${contato.id}'),
              initialValue: contato.observacao,
              readOnly: true,
              maxLines: 3,
              decoration: const InputDecoration(
                  labelText: 'Observações', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            // Navegação
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.skip_previous),
                  tooltip: 'Primeiro',
                  onPressed: provider.currentIndex > 0
                      ? () => provider.goToFirst()
                      : null,
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  tooltip: 'Anterior',
                  onPressed: provider.currentIndex > 0
                      ? () => provider.goToPrevious()
                      : null,
                ),
                Text(
                  '${provider.currentIndex + 1} / ${provider.contatos.length}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  tooltip: 'Próximo',
                  onPressed:
                      provider.currentIndex < provider.contatos.length - 1
                          ? () => provider.goToNext()
                          : null,
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next),
                  tooltip: 'Último',
                  onPressed:
                      provider.currentIndex < provider.contatos.length - 1
                          ? () => provider.goToLast()
                          : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  
  Widget _buildProfileImage(String path, String id) {
    ImageProvider provider;
    if (path.startsWith('http')) {
      provider = NetworkImage(path);
    } else if (path.isNotEmpty) {
      provider = FileImage(File(path));
    } else {
      provider = const AssetImage('assets/images/default_avatar.png');
    }

    return ClipOval(
      key: ValueKey('foto_$id'), 
      child: Image(
        image: provider,
        width: 120,
        height: 120,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 120,
            height: 120,
            color: Colors.grey[300],
            child: const Icon(Icons.person, size: 60, color: Colors.white),
          );
        },
      ),
    );
  }
}