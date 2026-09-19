import 'tree_snapshot.dart';

class PatriciaNode {
  String label;
  final Map<String, PatriciaNode> children = {};
  bool isEnd = false;

  PatriciaNode(this.label);

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'isEnd': isEnd,
      'children': children.map((k, v) => MapEntry(k, v.toMap())),
    };
  }
}

class PatriciaTree {
  PatriciaNode root = PatriciaNode("");
  final List<TreeSnapshot> history = [];

  void insert(String word) {
    if (word.isEmpty) {
      _recordHistory('insert_empty', word);
      return;
    }
    _insertRec(root, word);
    _recordHistory('insert', word);
  }

  void _insertRec(PatriciaNode node, String word) {
    for (String key in node.children.keys) {
      PatriciaNode child = node.children[key]!;
      int commonPrefixLen = _getCommonPrefixLength(child.label, word);

      if (commonPrefixLen > 0) {
        if (commonPrefixLen == child.label.length) {
          if (commonPrefixLen == word.length) {
            child.isEnd = true;
          } else {
            _insertRec(child, word.substring(commonPrefixLen));
          }
          return;
        }

        // Split the node
        PatriciaNode splitNode = PatriciaNode(child.label.substring(commonPrefixLen));
        splitNode.isEnd = child.isEnd;
        splitNode.children.addAll(child.children);

        child.label = child.label.substring(0, commonPrefixLen);
        child.children.clear();
        child.children[splitNode.label[0]] = splitNode;

        if (commonPrefixLen == word.length) {
          child.isEnd = true;
        } else {
          String remainingWord = word.substring(commonPrefixLen);
          PatriciaNode newNode = PatriciaNode(remainingWord);
          newNode.isEnd = true;
          child.children[remainingWord[0]] = newNode;
          child.isEnd = false; // it was split, so it might not be an end anymore unless it was the exact word
        }
        return;
      }
    }

    // No common prefix found among children, add as new child
    PatriciaNode newNode = PatriciaNode(word);
    newNode.isEnd = true;
    node.children[word[0]] = newNode;
  }

  bool search(String word) {
    bool found = _searchRec(root, word);
    _recordHistory(found ? 'search_found' : 'search_not_found', word);
    return found;
  }

  bool _searchRec(PatriciaNode node, String word) {
    if (word.isEmpty) return node.isEnd;

    for (String key in node.children.keys) {
      PatriciaNode child = node.children[key]!;
      int commonPrefixLen = _getCommonPrefixLength(child.label, word);

      if (commonPrefixLen == child.label.length) {
        if (commonPrefixLen == word.length) {
          return child.isEnd;
        }
        return _searchRec(child, word.substring(commonPrefixLen));
      }
    }
    return false;
  }

  bool delete(String word) {
    bool removed = _deleteRec(root, word);
    _recordHistory(removed ? 'delete' : 'delete_not_found', word);
    return removed;
  }

  bool _deleteRec(PatriciaNode node, String word) {
    // simplified deletion: just unset isEnd flag. True compaction is complex.
    for (String key in node.children.keys) {
      PatriciaNode child = node.children[key]!;
      int commonPrefixLen = _getCommonPrefixLength(child.label, word);

      if (commonPrefixLen == child.label.length) {
        if (commonPrefixLen == word.length) {
          if (!child.isEnd) return false;
          child.isEnd = false;
          // Clean up if it's a leaf
          if (child.children.isEmpty) {
            node.children.remove(key);
          } else if (child.children.length == 1) {
            // merge with single child
            String singleKey = child.children.keys.first;
            PatriciaNode singleChild = child.children[singleKey]!;
            child.label += singleChild.label;
            child.isEnd = singleChild.isEnd;
            child.children.clear();
            child.children.addAll(singleChild.children);
          }
          return true;
        }
        return _deleteRec(child, word.substring(commonPrefixLen));
      }
    }
    return false;
  }

  int _getCommonPrefixLength(String str1, String str2) {
    int minLen = str1.length < str2.length ? str1.length : str2.length;
    for (int i = 0; i < minLen; i++) {
      if (str1[i] != str2[i]) return i;
    }
    return minLen;
  }

  List<String> allWords() {
    List<String> results = [];
    _collectWords(root, '', results);
    return results;
  }

  void _collectWords(PatriciaNode node, String prefix, List<String> results) {
    if (node.isEnd && node != root) {
      results.add(prefix);
    }
    
    final sortedKeys = node.children.keys.toList()..sort();
    for (String key in sortedKeys) {
      PatriciaNode child = node.children[key]!;
      _collectWords(child, prefix + child.label, results);
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
