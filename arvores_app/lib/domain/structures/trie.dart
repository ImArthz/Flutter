import 'tree_snapshot.dart';

class TrieNode {
  final Map<String, TrieNode> children = {};
  bool isEnd = false;
  int count = 0;

  Map<String, dynamic> toMap() {
    return {
      'isEnd': isEnd,
      'count': count,
      'children': children.map((k, v) => MapEntry(k, v.toMap())),
    };
  }
}

class Trie {
  TrieNode root = TrieNode();
  final List<TreeSnapshot> history = [];

  void insert(String word) {
    if (word.isEmpty) {
      _recordHistory('insert_empty', word);
      return;
    }
    TrieNode node = root;
    for (int i = 0; i < word.length; i++) {
      String char = word[i];
      node.children.putIfAbsent(char, () => TrieNode());
      node = node.children[char]!;
    }
    if (!node.isEnd) {
      node.isEnd = true;
    }
    node.count++;
    _recordHistory('insert', word);
  }

  bool search(String word) {
    TrieNode? node = _traverse(word);
    bool found = node != null && node.isEnd;
    _recordHistory(found ? 'search_found' : 'search_not_found', word);
    return found;
  }

  bool startsWith(String prefix) {
    bool found = _traverse(prefix) != null;
    _recordHistory(found ? 'starts_with_found' : 'starts_with_not_found', prefix);
    return found;
  }

  bool delete(String word) {
    bool removed = _deleteRec(root, word, 0);
    _recordHistory(removed ? 'delete' : 'delete_not_found', word);
    return removed;
  }

  bool _deleteRec(TrieNode node, String word, int depth) {
    if (depth == word.length) {
      if (!node.isEnd) return false;
      node.isEnd = false;
      node.count = (node.count > 0) ? node.count - 1 : 0;
      return node.children.isEmpty;
    }

    String char = word[depth];
    if (!node.children.containsKey(char)) return false;

    bool shouldDeleteChild = _deleteRec(node.children[char]!, word, depth + 1);

    if (shouldDeleteChild) {
      node.children.remove(char);
      return !node.isEnd && node.children.isEmpty;
    }
    return false;
  }

  List<String> autocomplete(String prefix) {
    TrieNode? node = _traverse(prefix);
    if (node == null) return [];
    
    List<String> results = [];
    _collectWords(node, prefix, results);
    _recordHistory('autocomplete', prefix);
    return results;
  }

  List<String> allWords() {
    List<String> results = [];
    _collectWords(root, '', results);
    return results;
  }

  TrieNode? _traverse(String text) {
    TrieNode node = root;
    for (int i = 0; i < text.length; i++) {
      String char = text[i];
      if (!node.children.containsKey(char)) return null;
      node = node.children[char]!;
    }
    return node;
  }

  void _collectWords(TrieNode node, String prefix, List<String> results) {
    if (node.isEnd) results.add(prefix);
    
    // Sort keys to maintain predictable order
    final sortedKeys = node.children.keys.toList()..sort();
    for (String char in sortedKeys) {
      _collectWords(node.children[char]!, prefix + char, results);
    }
  }

  void _recordHistory(String operation, String key) {
    history.add(TreeSnapshot(
      step: history.length + 1,
      operation: operation,
      key: key,
      rootKey: 'root',
      treeMap: root.toMap(),
      inorder: allWords(),
    ));
  }
}
