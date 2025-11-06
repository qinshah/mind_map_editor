import 'package:flutter/painting.dart';

class MindMapTheme {
  final double spacingBetweenSubTree;

  final double spacingWithSubTree;

  const MindMapTheme({
    this.spacingBetweenSubTree = 4,
    this.spacingWithSubTree = 20,
  });
}

class NodeTheme {
  final TextStyle? textStyle;

  final Color color;

  final EdgeInsets padding;

  const NodeTheme({
    this.textStyle,
    required this.color,
    this.padding = const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
  });
}
