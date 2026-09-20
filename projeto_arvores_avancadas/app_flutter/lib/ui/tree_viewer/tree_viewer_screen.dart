import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/structures/splay_tree.dart';
import '../../domain/structures/treap.dart';
import '../../domain/structures/trie.dart';
import '../../domain/structures/patricia_tree.dart';
import '../../domain/structures/kd_tree.dart';
import '../../domain/structures/tree_snapshot.dart';
import 'tree_painter.dart';

class TreeViewerScreen extends StatefulWidget {
  final TreeStructure structure;

  const TreeViewerScreen({super.key, required this.structure});

  @override
  State<TreeViewerScreen> createState() => _TreeViewerScreenState();
}

class _TreeViewerScreenState extends State<TreeViewerScreen> {
  dynamic _treeInstance;
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _inputYController = TextEditingController(); // Apenas para KD-Tree
  int _currentStep = 0;
  bool _isSimulating = false;

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

  dynamic _parseInput(String text, [String? textY]) {
    if (text.isEmpty) return null;
    if (widget.structure == TreeStructure.kdTree) {
      final x = double.tryParse(text);
      final y = double.tryParse(textY ?? '');
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
    final val = _parseInput(_inputController.text.trim(), _inputYController.text.trim());
    if (val == null) return;
    _treeInstance!.insert(val);
    _inputController.clear();
    _inputYController.clear();
    _syncStep();
  }

  void _onSearch() {
    final val = _parseInput(_inputController.text.trim(), _inputYController.text.trim());
    if (val == null) return;
    _treeInstance!.search(val);
    _syncStep();
  }

  void _onDelete() {
    final val = _parseInput(_inputController.text.trim(), _inputYController.text.trim());
    if (val == null) return;
    _treeInstance!.delete(val);
    _inputController.clear();
    _inputYController.clear();
    _syncStep();
  }

  void _simulateExample() async {
    if (_isSimulating) return;
    setState(() {
      _isSimulating = true;
      _initTree();
      _currentStep = 0;
    });

    List<Map<String, dynamic>> operations = [];
    if (widget.structure == TreeStructure.kdTree) {
      operations = [
        {'op': 'ins', 'val': Point2D(5, 5)},
        {'op': 'ins', 'val': Point2D(3, 2)},
        {'op': 'ins', 'val': Point2D(7, 8)},
        {'op': 'ins', 'val': Point2D(2, 3)},
        {'op': 'del', 'val': Point2D(3, 2)},
      ];
    } else if (widget.structure.isStringBased) {
      operations = [
        {'op': 'ins', 'val': 'flutter'},
        {'op': 'ins', 'val': 'flutuante'},
        {'op': 'ins', 'val': 'arvore'},
        {'op': 'ins', 'val': 'arte'},
        {'op': 'del', 'val': 'arvore'},
      ];
    } else {
      operations = [
        {'op': 'ins', 'val': 50},
        {'op': 'ins', 'val': 30},
        {'op': 'ins', 'val': 70},
        {'op': 'ins', 'val': 20},
        {'op': 'ins', 'val': 40},
        {'op': 'del', 'val': 30},
        {'op': 'ins', 'val': 60},
      ];
    }

    for (var step in operations) {
      if (!mounted || !_isSimulating) break;
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted || !_isSimulating) break;
      
      if (step['op'] == 'ins') {
        _treeInstance!.insert(step['val']);
      } else if (step['op'] == 'del') {
        _treeInstance!.delete(step['val']);
      }
      _syncStep();
    }
    
    if (mounted) {
      setState(() {
        _isSimulating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentSnapshot = _history.isEmpty ? null : _history[_currentStep];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.structure.title),
        actions: [
          if (_isSimulating)
            IconButton(
              icon: const Icon(Icons.stop_circle_outlined, color: Colors.amberAccent),
              tooltip: 'Parar Simulação',
              onPressed: () => setState(() => _isSimulating = false),
            )
          else
            IconButton(
              icon: const Icon(Icons.play_circle_outline),
              tooltip: 'Simular Exemplo (Automático)',
              onPressed: _simulateExample,
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Limpar Árvore',
            onPressed: () {
              setState(() {
                _isSimulating = false;
                _initTree();
                _currentStep = 0;
              });
            },
          )
        ],
      ),
      body: Column(
        children: [
          // ÁREA DE DESENHO (Interactive Viewer)
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
                  boundaryMargin: const EdgeInsets.all(1000),
                  minScale: 0.1,
                  maxScale: 2.0,
                  child: Center(
                    child: currentSnapshot?.treeMap == null || currentSnapshot?.treeMap!.isEmpty == true
                      ? const Padding(
                          padding: EdgeInsets.all(64.0),
                          child: Text('Árvore Vazia.\nDigite um valor e insira\nou aperte Play no topo.', 
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.textDisabled, fontSize: 18)),
                        )
                      : CustomPaint(
                          size: const Size(1200, 1200), // Base canvas size
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
          
          // INFO DO PASSO ATUAL (Painel Moderno)
          if (currentSnapshot != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        currentSnapshot.operation == 'insert' ? Icons.add_circle :
                        currentSnapshot.operation == 'delete' ? Icons.remove_circle : Icons.search,
                        color: currentSnapshot.operation == 'insert' ? AppColors.secondary :
                               currentSnapshot.operation == 'delete' ? AppColors.error : AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text('Operação: ${currentSnapshot.operation.toUpperCase()} | Chave: ${currentSnapshot.key}', 
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  if (currentSnapshot.inorder.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text('Em-ordem: ${currentSnapshot.inorder.join(", ")}', 
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
            
          // CONTROLES DE HISTÓRICO
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.first_page),
                  onPressed: _currentStep > 0 && !_isSimulating ? () => setState(() => _currentStep = 0) : null,
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _currentStep > 0 && !_isSimulating ? () => setState(() => _currentStep--) : null,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('Passo ${_currentStep} / ${_history.length > 0 ? _history.length - 1 : 0}', 
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _currentStep < _history.length - 1 && !_isSimulating ? () => setState(() => _currentStep++) : null,
                ),
                IconButton(
                  icon: const Icon(Icons.last_page),
                  onPressed: _currentStep < _history.length - 1 && !_isSimulating ? () => setState(() => _currentStep = _history.length - 1) : null,
                ),
              ],
            ),
          ),
            
          // INPUT CONTROLS (Modernos)
          Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    enabled: !_isSimulating,
                    decoration: InputDecoration(
                      hintText: widget.structure == TreeStructure.kdTree ? 'X...' : 'Valor...',
                    ),
                    keyboardType: widget.structure.isStringBased ? TextInputType.text : const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                if (widget.structure == TreeStructure.kdTree) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _inputYController,
                      enabled: !_isSimulating,
                      decoration: const InputDecoration(hintText: 'Y...'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                ],
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isSimulating ? null : _onInsert, 
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
                  child: const Text('Ins'),
                ),
                const SizedBox(width: 4),
                OutlinedButton(
                  onPressed: _isSimulating ? null : _onSearch,
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
                  child: const Text('Bus'),
                ),
                const SizedBox(width: 4),
                TextButton(
                  onPressed: _isSimulating ? null : _onDelete,
                  style: TextButton.styleFrom(foregroundColor: AppColors.error, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
                  child: const Text('Del'),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
