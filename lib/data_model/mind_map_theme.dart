import 'package:flutter/painting.dart';

class MindMapTheme {
  final double spacingBetweenChild;

  final double spacingWithChild;

  const MindMapTheme({
    this.spacingBetweenChild = 4,
    this.spacingWithChild = 20,
  });
}

class NodeTheme {
  final TextStyle? textStyle;

  final Color? color;

  final EdgeInsets padding;

  const NodeTheme({
    this.textStyle,
    this.color,
    this.padding = const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
  });
}
