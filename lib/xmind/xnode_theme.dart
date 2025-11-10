import 'package:flutter/painting.dart';
class XnodeTheme {
  final TextStyle? textStyle;

  final Color color;

  final EdgeInsets padding;

  const XnodeTheme({
    this.textStyle,
    required this.color,
    this.padding = const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
  });
}
