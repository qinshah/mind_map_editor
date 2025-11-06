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
    final color = depth == 1
        ? Theme.of(context).colorScheme.primary
        // 控制相同分支色调一致
        : Colors.primaries[node.path[1] % Colors.primaries.length].withAlpha(
            255 - 60 * (depth - 2).clamp(0, 1), // 越深颜色越浅
          );
    final textColor = color.computeLuminance() > 0.5
        ? Colors.black
        : Colors.white;
    final theme = depth == 1
        // 根节点
        ? NodeTheme(
            color: color,
            textStyle: TextStyle(
              color: textColor,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
          )
        : depth == 2
        // 一级分支节点
        ? NodeTheme(
            color: color,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
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
    return InkWell(
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
