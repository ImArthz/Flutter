import 'dart:math';
import 'tree_snapshot.dart';

class Point2D {
  final double x;
  final double y;

  Point2D(this.x, this.y);

  double distanceTo(Point2D other) {
    return sqrt(pow(x - other.x, 2) + pow(y - other.y, 2));
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Point2D &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y;

  @override
  int get hashCode => x.hashCode ^ y.hashCode;

  @override
  String toString() => '($x, $y)';
}

class KDNode {
  Point2D point;
  int axis; // 0 for x, 1 for y
  KDNode? left;
  KDNode? right;

  KDNode(this.point, this.axis);

  Map<String, dynamic> toMap() {
    return {
      'x': point.x,
      'y': point.y,
      'axis': axis,
      'left': left?.toMap(),
      'right': right?.toMap(),
    };
  }
}

class KDTree {
  KDNode? root;
  final List<TreeSnapshot> history = [];

  void insert(Point2D point) {
    root = _insertRec(root, point, 0);
    _recordHistory('insert', point.toString());
  }

  KDNode? _insertRec(KDNode? node, Point2D point, int depth) {
    if (node == null) {
      return KDNode(point, depth % 2);
    }

    if (node.point == point) {
      return node; // duplicatas ignoradas
    }

    int axis = depth % 2;
    double currentVal = axis == 0 ? node.point.x : node.point.y;
    double insertVal = axis == 0 ? point.x : point.y;

    if (insertVal < currentVal) {
      node.left = _insertRec(node.left, point, depth + 1);
    } else {
      node.right = _insertRec(node.right, point, depth + 1);
    }

    return node;
  }

  bool search(Point2D point) {
    bool found = _searchRec(root, point, 0);
    _recordHistory(found ? 'search_found' : 'search_not_found', point.toString());
    return found;
  }

  bool _searchRec(KDNode? node, Point2D point, int depth) {
    if (node == null) return false;
    if (node.point == point) return true;

    int axis = depth % 2;
    double currentVal = axis == 0 ? node.point.x : node.point.y;
    double searchVal = axis == 0 ? point.x : point.y;

    if (searchVal < currentVal) {
      return _searchRec(node.left, point, depth + 1);
    } else {
      return _searchRec(node.right, point, depth + 1);
    }
  }

  bool delete(Point2D point) {
    // A deleção em KD-Tree realocando nós é muito complexa para visualização simples.
    // Usualmente em aplicações de tempo real se marca o nó como removido (lazy deletion).
    // Implementarei a busca para retornar false caso a árvore seja usada em benchmark,
    // ou se necessário, apenas falharei graciosamente.
    // Para simplificar a visualização educacional e benchmarks, usaremos reconstrução ou não suportaremos remoção direta.
    _recordHistory('delete_not_supported', point.toString());
    return false; 
  }

  List<String> inorder() {
    List<String> results = [];
    _inorderRec(root, results);
    return results;
  }

  void _inorderRec(KDNode? node, List<String> results) {
    if (node != null) {
      _inorderRec(node.left, results);
      results.add(node.point.toString());
      _inorderRec(node.right, results);
    }
  }

  void _recordHistory(String operation, String key) {
    history.add(TreeSnapshot(
      step: history.length + 1,
      operation: operation,
      key: key,
      rootKey: root?.point.toString(),
      treeMap: root?.toMap(),
      inorder: inorder(),
    ));
  }
}
