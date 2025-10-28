import 'package:flutter/painting.dart';

class MindMapTheme {
  final double spacingBetweenChild;

  final double spacingBetweenParentAndChild;

  const MindMapTheme({
    this.spacingBetweenChild = 3,
    this.spacingBetweenParentAndChild = 20,
  });
}

class NodeTheme {
  final TextStyle? textStyle;

  final Color? color;

  final EdgeInsets padding;

  const NodeTheme({
    this.textStyle,
    this.color,
    this.padding = const EdgeInsets.all(8),
  });
}
