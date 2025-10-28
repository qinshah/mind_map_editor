import 'package:flutter/material.dart';
import 'package:mind_map_editor/data_model/mind_map_theme.dart';
import 'package:mind_map_editor/data_model/xmind.dart';

class NodeWidget extends StatelessWidget {
  const NodeWidget(this.node, {super.key, this.onTap});

  final VoidCallback? onTap;
  final Node node;

  @override
  Widget build(BuildContext context) {
    final depth = node.path.length;
    final color = node.path.isEmpty
        ? Theme.of(context).colorScheme.primary
        // 控制相同分支色调一致
        : Colors.primaries[node.path.first % Colors.primaries.length].withAlpha(
            255 - 60 * (depth - 1).clamp(0, 1), // 越深颜色越浅
          );
    final textColor = color.computeLuminance() > 0.5
        ? Colors.black
        : Colors.white;
    final theme = depth == 0
        ? NodeTheme(
            color: color,
            textStyle: TextStyle(
              color: textColor,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 10),
          )
        : depth == 1
        ? NodeTheme(
            color: color,
            textStyle: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          )
        : NodeTheme(
            color: color,
            textStyle: TextStyle(color: textColor),
          );
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: theme.padding,
        decoration: BoxDecoration(
          color: theme.color,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(node.title, style: theme.textStyle),
      ),
    );
  }
}
