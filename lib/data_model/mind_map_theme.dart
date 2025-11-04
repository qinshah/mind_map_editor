import 'package:flutter/painting.dart';

class MindMapTheme {
  final double spacingWithBrother;

  final double spacingWithChild;

  final double spacingWithParent;

  const MindMapTheme({
    this.spacingWithBrother = 4,
    this.spacingWithChild = 10,
    this.spacingWithParent = 10,
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
