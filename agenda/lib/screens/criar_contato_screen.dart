import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/contato.dart';
import '../providers/contatos_provider.dart';

class CriarContatoScreen extends StatefulWidget {
  final VoidCallback onSave;
  const CriarContatoScreen({super.key, required this.onSave});

  @override
  State<CriarContatoScreen> createState() => _CriarContatoScreenState();
}

class _CriarContatoScreenState extends State<CriarContatoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _enderecoController = TextEditingController();
  final _obsController = TextEditingController();
  late String _fotoPerfil;

  @override
  void initState() {
    super.initState();
    _gerarImagemAleatoria();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _telefoneController.dispose();
    _enderecoController.dispose();
    _obsController.dispose();
    super.dispose();
  }

  void _gerarImagemAleatoria() {
    final random = Random();
    final seed = '${random.nextInt(99999)}${DateTime.now().millisecondsSinceEpoch}';
    setState(() {
      _fotoPerfil = 'https://picsum.photos/seed/$seed/200/200';
    });
  }

  void _salvar() {
    if (_formKey.currentState!.validate()) {
      final provider = context.read<ContatosProvider>();
      final novoId = DateTime.now().millisecondsSinceEpoch.toString();
      final novoContato = Contato(
        id: novoId,
        nome: _nomeController.text,
        telefone: _telefoneController.text,
        endereco: _enderecoController.text,
        fotoPerfil: _fotoPerfil,
        observacao: _obsController.text,
      );
      provider.addContato(novoContato);
      widget.onSave(); // volta para a aba Início
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar Contato')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _gerarImagemAleatoria,
                child: ClipOval(
                  child: Image.network(
                    _fotoPerfil,
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 120,
                        height: 120,
                        color: Colors.grey[300],
                        child: const Icon(Icons.person,
                            size: 60, color: Colors.white),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: _gerarImagemAleatoria,
                icon: const Icon(Icons.shuffle),
                label: const Text('Gerar outra imagem'),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                    labelText: 'Nome *', border: OutlineInputBorder()),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _telefoneController,
                decoration: const InputDecoration(
                    labelText: 'Telefone *', border: OutlineInputBorder()),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _enderecoController,
                decoration: const InputDecoration(
                    labelText: 'Endereço', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _obsController,
                maxLines: 3,
                decoration: const InputDecoration(
                    labelText: 'Observações', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50)),
                onPressed: _salvar,
                icon: const Icon(Icons.save),
                label: const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}