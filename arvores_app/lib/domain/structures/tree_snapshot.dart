class TreeSnapshot {
  final int step;
  final String operation;
  final dynamic key;
  final dynamic rootKey;
  final Map<String, dynamic>? treeMap;
  final List<dynamic> inorder;

  TreeSnapshot({
    required this.step,
    required this.operation,
    required this.key,
    this.rootKey,
    this.treeMap,
    required this.inorder,
  });
}
