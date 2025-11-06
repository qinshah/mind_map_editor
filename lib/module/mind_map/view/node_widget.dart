import 'package:flutter/material.dart';
import 'package:mind_map_editor/data_model/mind_map_theme.dart';
import 'package:mind_map_editor/data_model/xmind.dart';
import 'package:mind_map_editor/module/editor/editor_notifier.dart';
import 'package:provider/provider.dart';

class NodeWidget extends StatelessWidget {
  const NodeWidget(this.node, {super.key, this.onTap});

  final VoidCallback? onTap;
  final Node node;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final depth = node.path.length;
    final color = depth == 1
        ? primaryColor
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
    final state = context.read<EditorNotifier>().state;
    final borderRadius = BorderRadius.circular(6);
    return DragTarget<Node>(
      onMove: (details) {
        final draggingNode = details.data;
        if (draggingNode.id == node.id) return;
        // TODO 通过拖拽实现思维导图节点的移动
        print(draggingNode.title);
        print(details.offset);
      },
      builder: (_, _, _) {
        return LongPressDraggable(
          data: node,
          feedback: Transform.scale(
            scale: state.scale / 100,
            child: Material(
              color: Colors.transparent,
              child: _buildChild(theme, borderRadius, alpha: 200),
            ),
          ),
          childWhenDragging: _buildChild(theme, borderRadius, alpha: 50),
          child: _buildChild(theme, borderRadius),
        );
      },
    );
  }

  Widget _buildChild(NodeTheme theme, BorderRadius borderRadius, {int? alpha}) {
    return Ink(
      decoration: BoxDecoration(
        color: alpha == null ? theme.color : theme.color.withAlpha(alpha),
        borderRadius: borderRadius,
      ),
      child: InkWell(
        borderRadius: borderRadius,
        onTap: onTap,
        child: Padding(
          padding: theme.padding,
          child: Text(node.title, style: theme.textStyle),
        ),
      ),
    );
  }
}
