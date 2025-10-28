import 'package:flutter/material.dart';
import 'package:mind_map_editor/data_model/xmind.dart';

class NodeWidget extends StatelessWidget {
  const NodeWidget(this.node, {super.key, this.onTap});

  final VoidCallback? onTap;
  final Node node;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final depth = node.path.length;
    final color = node.path.isEmpty
        ? theme.colorScheme.primary
        // 控制相同分支色调一致
        : Colors.primaries[node.path.first % Colors.primaries.length].withAlpha(
            255 ~/ depth.clamp(1, 3), // 越深颜色越浅，3以后都一样
          );
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          node.title,
          style: TextStyle(
            fontSize: 14,
            color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
          ),
        ),
      ),
    );
  }
}
