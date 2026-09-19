import 'dart:math';
import 'tree_snapshot.dart';

class TreapNode<T extends Comparable<T>> {
  T key;
  double priority;
  TreapNode<T>? left;
  TreapNode<T>? right;

  TreapNode(this.key, this.priority);

  Map<String, dynamic> toMap() {
    return {
      'key': key,
      'priority': priority,
      'left': left?.toMap(),
      'right': right?.toMap(),
    };
  }
}

class Treap<T extends Comparable<T>> {
  TreapNode<T>? root;
  final List<TreeSnapshot> history = [];
  final Random _random = Random();

  TreapNode<T> _rotateRight(TreapNode<T> y) {
    TreapNode<T> x = y.left!;
    TreapNode<T>? t2 = x.right;
    x.right = y;
    y.left = t2;
    return x;
  }

  TreapNode<T> _rotateLeft(TreapNode<T> x) {
    TreapNode<T> y = x.right!;
    TreapNode<T>? t2 = y.left;
    y.left = x;
    x.right = t2;
    return y;
  }

  void insert(T key) {
    root = _insertRec(root, key, _random.nextDouble());
    _recordHistory('insert', key);
  }

  TreapNode<T>? _insertRec(TreapNode<T>? node, T key, double priority) {
    if (node == null) return TreapNode(key, priority);

    if (key == node.key) {
      return node; // duplicatas ignoradas
    }

    if (key.compareTo(node.key) < 0) {
      node.left = _insertRec(node.left, key, priority);
      if (node.left!.priority > node.priority) {
        node = _rotateRight(node);
      }
    } else {
      node.right = _insertRec(node.right, key, priority);
      if (node.right!.priority > node.priority) {
        node = _rotateLeft(node);
      }
    }
    return node;
  }

  bool search(T key) {
    TreapNode<T>? current = root;
    while (current != null) {
      if (key == current.key) {
        _recordHistory('search_found', key);
        return true;
      } else if (key.compareTo(current.key) < 0) {
        current = current.left;
      } else {
        current = current.right;
      }
    }
    _recordHistory('search_not_found', key);
    return false;
  }

  bool delete(T key) {
    bool found = false;
    root = _deleteRec(root, key, (f) => found = f);
    _recordHistory(found ? 'delete' : 'delete_not_found', key);
    return found;
  }

  TreapNode<T>? _deleteRec(TreapNode<T>? node, T key, Function(bool) setFound) {
    if (node == null) return null;

    if (key.compareTo(node.key) < 0) {
      node.left = _deleteRec(node.left, key, setFound);
    } else if (key.compareTo(node.key) > 0) {
      node.right = _deleteRec(node.right, key, setFound);
    } else {
      setFound(true);
      if (node.left == null) {
        return node.right;
      } else if (node.right == null) {
        return node.left;
      }

      if (node.left!.priority > node.right!.priority) {
        node = _rotateRight(node);
        node.right = _deleteRec(node.right, key, setFound);
      } else {
        node = _rotateLeft(node);
        node.left = _deleteRec(node.left, key, setFound);
      }
    }
    return node;
  }

  List<T> inorder() {
    final result = <T>[];
    _inorderRec(root, result);
    return result;
  }

  void _inorderRec(TreapNode<T>? node, List<T> result) {
    if (node != null) {
      _inorderRec(node.left, result);
      result.add(node.key);
      _inorderRec(node.right, result);
    }
  }

  void _recordHistory(String operation, T key) {
    history.add(TreeSnapshot(
      step: history.length + 1,
      operation: operation,
      key: key,
      rootKey: root?.key,
      treeMap: root?.toMap(),
      inorder: inorder(),
    ));
  }
}
