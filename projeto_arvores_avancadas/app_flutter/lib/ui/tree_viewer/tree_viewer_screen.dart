import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/structures/tree_snapshot.dart';
import '../../domain/structures/splay_tree.dart';
import '../../domain/structures/treap.dart';
import '../../domain/structures/trie.dart';
import '../../domain/structures/patricia_tree.dart';
import '../../domain/structures/kd_tree.dart';
import 'tree_painter.dart';

class TreeViewerScreen extends StatefulWidget {
  final TreeStructure structure;
  const TreeViewerScreen({super.key, required this.structure});

  @override
  State<TreeViewerScreen> createState() => _TreeViewerScreenState();
}

class _TreeViewerScreenState extends State<TreeViewerScreen> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _inputYController = TextEditingController(); // For KD-Tree Y value
  int _currentStep = 0;
  
  // Generic wrapper to hold the chosen structure
  dynamic _treeInstance;

  @override
  void initState() {
    super.initState();
    _initTree();
  }

  void _initTree() {
    switch (widget.structure) {
      case TreeStructure.splay:
        _treeInstance = SplayTree<num>();
        break;
      case TreeStructure.treap:
        _treeInstance = Treap<num>();
        break;
      case TreeStructure.trie:
        _treeInstance = Trie();
        break;
      case TreeStructure.patricia:
        _treeInstance = PatriciaTree();
        break;
      case TreeStructure.kdTree:
        _treeInstance = KDTree();
        break;
    }
  }

  List<TreeSnapshot> get _history {
    if (_treeInstance == null) return [];
    return _treeInstance!.history;
  }

  void _syncStep() {
    setState(() {
      if (_history.isNotEmpty) {
        _currentStep = _history.length - 1;
      }
    });
  }

  dynamic _parseInput() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return null;
    
    if (widget.structure == TreeStructure.kdTree) {
      final textY = _inputYController.text.trim();
      final x = double.tryParse(text);
      final y = double.tryParse(textY);
      if (x != null && y != null) {
        return Point2D(x, y);
      }
      return null;
    }
    
    if (widget.structure.isStringBased) {
      return text;
    } else {
      return num.tryParse(text);
    }
  }

  void _onInsert() {
    final val = _parseInput();
    if (val == null) return;
    _treeInstance!.insert(val);
    _inputController.clear();
    _inputYController.clear();
    _syncStep();
  }

  void _onSearch() {
    final val = _parseInput();
    if (val == null) return;
    _treeInstance!.search(val);
    _syncStep();
  }

  void _onDelete() {
    final val = _parseInput();
    if (val == null) return;
    _treeInstance!.delete(val);
    _inputController.clear();
    _inputYController.clear();
    _syncStep();
  }

  @override
  Widget build(BuildContext context) {
    final currentSnapshot = _history.isEmpty ? null : _history[_currentStep];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.structure.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reiniciar Árvore',
            onPressed: () {
              setState(() {
                _initTree();
                _currentStep = 0;
              });
            },
          )
        ],
      ),
      body: Column(
        children: [
          // 🌲🌲 VISUALIZADOR DA ÁRVORE (InteractiveViewer) 🌲🌲
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
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: InteractiveViewer(
                  constrained: false,
                  boundaryMargin: const EdgeInsets.all(500),
                  minScale: 0.1,
                  maxScale: 2.0,
                  child: Center(
                    child: currentSnapshot?.treeMap == null || currentSnapshot?.treeMap!.isEmpty == true
                      ? const Padding(
                          padding: EdgeInsets.all(64.0),
                          child: Text('Árvore Vazia', style: TextStyle(color: AppColors.textDisabled, fontSize: 18)),
                        )
                      : CustomPaint(
                          size: const Size(800, 800), // Base size, can pan around
                          painter: TreePainter(
                            treeMap: currentSnapshot!.treeMap, 
                            nodeColor: widget.structure.color
                          ),
                        ),
                  ),
                ),
              ),
            ),
          ),
          
          // 🌲🌲 HISTÓRICO E CONTROLES 🌲🌲
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
          
          // 🌲🌲 INFO DO PASSO 🌲🌲
          if (currentSnapshot != null)
            Container(
              padding: const EdgeInsets.all(12),
              width: double.infinity,
              color: Colors.white,
              child: Column(
                children: [
                  Text('Operação: ${currentSnapshot.operation.toUpperCase()} | Chave: ${currentSnapshot.key}', 
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                  if (currentSnapshot.inorder.isNotEmpty)
                    Text('Em-ordem: ${currentSnapshot.inorder.join(", ")}', 
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            
          // 🌲🌲 INPUT (Insert / Search / Delete) 🌲🌲
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    decoration: InputDecoration(
                      hintText: widget.structure == TreeStructure.kdTree ? 'X...' : 'Digite o valor...',
                      isDense: true,
                    ),
                    keyboardType: widget.structure.isStringBased ? TextInputType.text : const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                if (widget.structure == TreeStructure.kdTree) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _inputYController,
                      decoration: const InputDecoration(
                        hintText: 'Y...',
                        isDense: true,
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                ],
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
