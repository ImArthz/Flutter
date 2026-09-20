import 'package:flutter/material.dart';

class TreePainter extends CustomPainter {
  final Map<String, dynamic>? treeMap;
  final Color nodeColor;
  final double nodeRadius;
  final double levelHeight;

  TreePainter({
    required this.treeMap,
    required this.nodeColor,
    this.nodeRadius = 20,
    this.levelHeight = 60,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (treeMap == null) return;
    
    // First pass: Calculate node positions and bounding widths
    _NodePos rootPos = _layoutNode(treeMap!, 0);

    // Second pass: Draw lines
    _drawLines(canvas, rootPos, size.width / 2, 40);

    // Third pass: Draw nodes
    _drawNodes(canvas, rootPos, size.width / 2, 40);
  }

  _NodePos _layoutNode(Map<String, dynamic> map, int depth) {
    String key = map['key']?.toString() ?? map['isEnd']?.toString() ?? 'R';
    
    // Handle binary trees
    if (map.containsKey('left') || map.containsKey('right')) {
      _NodePos? leftChild;
      _NodePos? rightChild;
      
      double leftWidth = 0;
      double rightWidth = 0;
      
      if (map['left'] != null) {
        leftChild = _layoutNode(map['left'], depth + 1);
        leftWidth = leftChild.width;
      }
      if (map['right'] != null) {
        rightChild = _layoutNode(map['right'], depth + 1);
        rightWidth = rightChild.width;
      }
      
      double totalWidth = leftWidth + rightWidth;
      if (totalWidth < nodeRadius * 3) {
        totalWidth = nodeRadius * 3;
      }
      
      return _NodePos(
        label: key,
        width: totalWidth,
        depth: depth,
        children: [if (leftChild != null) leftChild, if (rightChild != null) rightChild],
        isBinary: true,
        binaryLeft: leftChild,
        binaryRight: rightChild,
      );
    } 
    // Handle Trie / Patricia Tree (N-ary)
    else if (map.containsKey('children')) {
      final childrenMap = map['children'] as Map<dynamic, dynamic>;
      List<_NodePos> children = [];
      double totalWidth = 0;
      
      childrenMap.forEach((k, v) {
        // For Trie, the edge has the character, but we don't have edge labels in our simple generic tree yet.
        // Actually, we can prepend the edge key to the child node label for visualization.
        final childPos = _layoutNode(v, depth + 1);
        childPos.edgeLabel = k.toString();
        children.add(childPos);
        totalWidth += childPos.width;
      });
      
      if (children.isEmpty) totalWidth = nodeRadius * 3;
      if (totalWidth < nodeRadius * 3) totalWidth = nodeRadius * 3;
      
      return _NodePos(
        label: map['isEnd'] == true ? '[$key]' : '($key)',
        width: totalWidth,
        depth: depth,
        children: children,
        isBinary: false,
      );
    }
    
    // Leaf node fallback
    return _NodePos(
      label: key,
      width: nodeRadius * 3,
      depth: depth,
      children: [],
    );
  }

  void _drawLines(Canvas canvas, _NodePos node, double x, double y) {
    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
      
    if (node.isBinary) {
      if (node.binaryLeft != null) {
        double childX = x - (node.width / 2) + (node.binaryLeft!.width / 2);
        double childY = y + levelHeight;
        canvas.drawLine(Offset(x, y), Offset(childX, childY), paint);
        _drawLines(canvas, node.binaryLeft!, childX, childY);
      }
      if (node.binaryRight != null) {
        double childX = x + (node.width / 2) - (node.binaryRight!.width / 2);
        double childY = y + levelHeight;
        canvas.drawLine(Offset(x, y), Offset(childX, childY), paint);
        _drawLines(canvas, node.binaryRight!, childX, childY);
      }
    } else {
      double startX = x - (node.width / 2);
      for (var child in node.children) {
        double childX = startX + (child.width / 2);
        double childY = y + levelHeight;
        canvas.drawLine(Offset(x, y), Offset(childX, childY), paint);
        
        if (child.edgeLabel != null) {
          _drawText(canvas, child.edgeLabel!, (x + childX) / 2, ((y + childY) / 2) - 10, Colors.black, 12, Colors.white);
        }
        
        _drawLines(canvas, child, childX, childY);
        startX += child.width;
      }
    }
  }

  void _drawNodes(Canvas canvas, _NodePos node, double x, double y) {
    final paint = Paint()
      ..color = nodeColor
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset(x, y), nodeRadius, paint);
    
    // Draw Border
    final borderPaint = Paint()
      ..color = Colors.black12
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(Offset(x, y), nodeRadius, borderPaint);
    
    // Text
    _drawText(canvas, node.label, x, y, Colors.white, 14, null);
    
    // Recursive draw children
    if (node.isBinary) {
      if (node.binaryLeft != null) {
        double childX = x - (node.width / 2) + (node.binaryLeft!.width / 2);
        double childY = y + levelHeight;
        _drawNodes(canvas, node.binaryLeft!, childX, childY);
      }
      if (node.binaryRight != null) {
        double childX = x + (node.width / 2) - (node.binaryRight!.width / 2);
        double childY = y + levelHeight;
        _drawNodes(canvas, node.binaryRight!, childX, childY);
      }
    } else {
      double startX = x - (node.width / 2);
      for (var child in node.children) {
        double childX = startX + (child.width / 2);
        double childY = y + levelHeight;
        _drawNodes(canvas, child, childX, childY);
        startX += child.width;
      }
    }
  }
  
  void _drawText(Canvas canvas, String text, double x, double y, Color color, double fontSize, Color? bgColor) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: TextStyle(color: color, fontSize: fontSize, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    
    if (bgColor != null) {
       final bgRect = Rect.fromCenter(center: Offset(x, y), width: textPainter.width + 4, height: textPainter.height + 4);
       canvas.drawRect(bgRect, Paint()..color = bgColor);
    }
    
    textPainter.paint(canvas, Offset(x - textPainter.width / 2, y - textPainter.height / 2));
  }

  @override
  bool shouldRepaint(covariant TreePainter oldDelegate) => true;
}

class _NodePos {
  String label;
  String? edgeLabel;
  double width;
  int depth;
  List<_NodePos> children;
  
  bool isBinary;
  _NodePos? binaryLeft;
  _NodePos? binaryRight;
  
  _NodePos({
    required this.label, 
    required this.width, 
    required this.depth, 
    required this.children,
    this.isBinary = false,
    this.binaryLeft,
    this.binaryRight,
  });
}
