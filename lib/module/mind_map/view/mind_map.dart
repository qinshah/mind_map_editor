import 'package:flutter/material.dart';
import 'package:mind_map_editor/data_model/mind_map_theme.dart';
import 'package:mind_map_editor/module/mind_map/mind_map_notifier.dart';
import 'package:mind_map_editor/module/mind_map/view/node_widget.dart';
import 'package:mind_map_editor/data_model/xmind.dart';
import 'package:provider/provider.dart';

class MindMap extends StatefulWidget {
  final Node rootNode;
  const MindMap(this.rootNode, {super.key});

  @override
  State<MindMap> createState() => _MindMapState();
}

class _MindMapState extends State<MindMap> {
  Node get node => widget.rootNode;

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<MindMapNotifier>();
    final expanded = notifier.getExpanded(node.id);
    final depth = node.path.length;
    final theme = depth == 1
        // 根节点
        ? MindMapTheme(spacingWithBrother: 0, spacingWithParent: 0)
        : depth == 2
        // 根节点的子节点
        ? MindMapTheme(spacingWithBrother: 10, spacingWithParent: 40)
        // 后面的节点
        : MindMapTheme();
    return Padding(
      padding: EdgeInsets.only(
        // 与前一个兄弟节点之间
        top: node.isFirstChild ? 0 : theme.spacingWithBrother,
        // 与父节点之间
        left: theme.spacingWithParent,
      ),
      child: Row(
        children: [
          // 根节点卡片
          NodeWidget(node, onTap: () => notifier.toggleExpand(node.id)),
          // 子节点区域
          if (expanded && node.childNodes.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(node.childNodes.length, (index) {
                final childNode = node.childNodes[index];
                return MindMap(childNode);
              }),
            ),
        ],
      ),
    );
  }
}
