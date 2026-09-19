import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/structures/tree_snapshot.dart';

class TreeViewerScreen extends StatefulWidget {
  final TreeStructure structure;
  // Instância da árvore correspondente será passada ou criada aqui
  // Para simplificar no scaffolding, vamos deixar um mock de history
  
  const TreeViewerScreen({super.key, required this.structure});

  @override
  State<TreeViewerScreen> createState() => _TreeViewerScreenState();
}

class _TreeViewerScreenState extends State<TreeViewerScreen> {
  final TextEditingController _inputController = TextEditingController();
  int _currentStep = 0;
  List<TreeSnapshot> _history = [];

  // TODO: Conectar com a instância real de cada árvore (SplayTree, Treap, etc.)
  
  @override
  void initState() {
    super.initState();
    // Inicia com um snapshot vazio
    _history.add(TreeSnapshot(step: 0, operation: 'init', key: '', inorder: []));
  }

  void _onInsert() {
    final val = _inputController.text;
    if (val.isEmpty) return;
    // TODO: Chamar insert na arvore correspondente
    _inputController.clear();
    setState(() {});
  }

  void _onSearch() {
    // TODO
  }

  void _onDelete() {
    // TODO
  }

  @override
  Widget build(BuildContext context) {
    final currentSnapshot = _history.isEmpty ? null : _history[_currentStep];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.structure.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              // TODO: Mostrar dialog com info teórica
            },
          )
        ],
      ),
      body: Column(
        children: [
          // ── VISUALIZADOR DA ÁRVORE (CustomPainter) ──
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))
                ]
              ),
              child: Center(
                child: currentSnapshot?.treeMap == null 
                  ? const Text('Árvore Vazia', style: TextStyle(color: AppColors.textDisabled))
                  : CustomPaint(
                      size: const Size(double.infinity, double.infinity),
                      painter: TreePainter(
                        treeMap: currentSnapshot!.treeMap, 
                        nodeColor: widget.structure.color
                      ),
                    ),
              ),
            ),
          ),
          
          // ── HISTÓRICO E CONTROLES ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppColors.surfaceAlt,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.first_page),
                  onPressed: _currentStep > 0 ? () => setState(() => _currentStep = 0) : null,
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _currentStep > 0 ? () => setState(() => _currentStep--) : null,
                ),
                Text('Passo ${_currentStep} / ${_history.length > 0 ? _history.length - 1 : 0}', 
                  style: const TextStyle(fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _currentStep < _history.length - 1 ? () => setState(() => _currentStep++) : null,
                ),
                IconButton(
                  icon: const Icon(Icons.last_page),
                  onPressed: _currentStep < _history.length - 1 ? () => setState(() => _currentStep = _history.length - 1) : null,
                ),
              ],
            ),
          ),
          
          // ── INFO DO PASSO ──
          if (currentSnapshot != null)
            Container(
              padding: const EdgeInsets.all(12),
              width: double.infinity,
              color: Colors.white,
              child: Column(
                children: [
                  Text('Operação: ${currentSnapshot.operation.toUpperCase()} | Chave: ${currentSnapshot.key}', 
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('Em-ordem: ${currentSnapshot.inorder.join(", ")}', 
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
            
          // ── INPUT (Insert / Search / Delete) ──
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    decoration: const InputDecoration(
                      hintText: 'Digite um valor...',
                      isDense: true,
                    ),
                    keyboardType: widget.structure.isStringBased ? TextInputType.text : TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: _onInsert, child: const Text('Ins')),
                const SizedBox(width: 4),
                OutlinedButton(onPressed: _onSearch, child: const Text('Bus')),
                const SizedBox(width: 4),
                TextButton(onPressed: _onDelete, child: const Text('Del', style: TextStyle(color: AppColors.error))),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// ── PAINTER BÁSICO (Mock - Será expandido) ──
class TreePainter extends CustomPainter {
  final Map<String, dynamic>? treeMap;
  final Color nodeColor;

  TreePainter({required this.treeMap, required this.nodeColor});

  @override
  void paint(Canvas canvas, Size size) {
    if (treeMap == null) return;
    final paint = Paint()..color = nodeColor..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width / 2, 40), 20, paint);
    
    // Draw text
    final textPainter = TextPainter(
      text: TextSpan(text: treeMap!['key']?.toString() ?? 'R', style: const TextStyle(color: Colors.white, fontSize: 16)),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width / 2 - textPainter.width / 2, 40 - textPainter.height / 2));
    
    // O algoritmo recursivo real de desenho requer calcular larguras. 
    // Como é extenso, implementaremos a lógica completa em tree_painter.dart
  }

  @override
  bool shouldRepaint(covariant TreePainter oldDelegate) => true;
}
