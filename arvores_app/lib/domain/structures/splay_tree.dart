import 'tree_snapshot.dart';

class SplayNode<T extends Comparable<T>> {
  T key;
  SplayNode<T>? left;
  SplayNode<T>? right;

  SplayNode(this.key);

  Map<String, dynamic> toMap() {
    return {
      'key': key,
      'left': left?.toMap(),
      'right': right?.toMap(),
    };
  }
}

class SplayTree<T extends Comparable<T>> {
  SplayNode<T>? root;
  final List<TreeSnapshot> history = [];

  SplayNode<T> _rotateRight(SplayNode<T> node) {
    final pivot = node.left!;
    node.left = pivot.right;
    pivot.right = node;
    return pivot;
  }

  SplayNode<T> _rotateLeft(SplayNode<T> node) {
    final pivot = node.right!;
    node.right = pivot.left;
    pivot.left = node;
    return pivot;
  }

  SplayNode<T>? _splay(SplayNode<T>? node, T key) {
    if (node == null || node.key == key) return node;

    if (key.compareTo(node.key) < 0) {
      if (node.left == null) return node;

      if (key.compareTo(node.left!.key) < 0) {
        node.left!.left = _splay(node.left!.left, key);
        node = _rotateRight(node);
      } else if (key.compareTo(node.left!.key) > 0) {
        node.left!.right = _splay(node.left!.right, key);
        if (node.left!.right != null) {
          node.left = _rotateLeft(node.left!);
        }
      }
      return node.left == null ? node : _rotateRight(node);
    } else {
      if (node.right == null) return node;

      if (key.compareTo(node.right!.key) > 0) {
        node.right!.right = _splay(node.right!.right, key);
        node = _rotateLeft(node);
      } else if (key.compareTo(node.right!.key) < 0) {
        node.right!.left = _splay(node.right!.left, key);
        if (node.right!.left != null) {
          node.right = _rotateRight(node.right!);
        }
      }
      return node.right == null ? node : _rotateLeft(node);
    }
  }

  void insert(T key) {
    if (root == null) {
      root = SplayNode(key);
      _recordHistory('insert', key);
      return;
    }

    root = _splay(root, key);
    if (root!.key == key) {
      _recordHistory('insert_duplicate', key);
      return;
    }

    final newNode = SplayNode(key);
    if (key.compareTo(root!.key) < 0) {
      newNode.right = root;
      newNode.left = root!.left;
      root!.left = null;
    } else {
      newNode.left = root;
      newNode.right = root!.right;
      root!.right = null;
    }
    root = newNode;
    _recordHistory('insert', key);
  }

  bool search(T key) {
    if (root == null) {
      _recordHistory('search_not_found', key);
      return false;
    }

    root = _splay(root, key);
    final found = root!.key == key;
    _recordHistory(found ? 'search_found' : 'search_not_found', key);
    return found;
  }

  bool delete(T key) {
    if (root == null) {
      _recordHistory('delete_not_found', key);
      return false;
    }

    root = _splay(root, key);
    if (root!.key != key) {
      _recordHistory('delete_not_found', key);
      return false;
    }

    final leftSub = root!.left;
    final rightSub = root!.right;

    if (leftSub == null) {
      root = rightSub;
    } else if (rightSub == null) {
      root = leftSub;
    } else {
      root = _splay(leftSub, key);
      root!.right = rightSub;
    }

    _recordHistory('delete', key);
    return true;
  }

  List<T> inorder() {
    final result = <T>[];
    _inorderRec(root, result);
    return result;
  }

  void _inorderRec(SplayNode<T>? node, List<T> result) {
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
