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
    final dividerColor = Theme.of(context).colorScheme.onSurface;
    final notifier = context.watch<MindMapNotifier>();
    final depth = node.path.length;
    final theme = depth == 1
        // 根节点
        ? MindMapTheme(
            spacingWithBrother: 0,
            spacingWithChild: 20,
            spacingWithParent: 0,
          )
        : depth == 2
        // 根节点的子节点
        ? MindMapTheme(
            spacingWithBrother: 20,
            spacingWithChild: 10,
            spacingWithParent: 20,
          )
        // 后面的节点
        : MindMapTheme();
    final nodeKey = Key(node.id);
    return Stack(
      children: [
        Container(
          // color: Colors.primaries[node.hashCode % Colors.primaries.length]
          //     .withAlpha(100),
          padding: EdgeInsets.only(
            // 与前一个兄弟节点之间
            top: node.isFirstChild ? 0 : theme.spacingWithBrother,
          ),
          child: Row(
            children: [
              // 与父节点之间连线
              SizedBox(
                width: theme.spacingWithParent,
                child: Divider(color: dividerColor),
              ),
              // 根节点卡片
              NodeWidget(
                key: nodeKey,
                node,
                onTap: () => notifier.toggleExpand(node.id),
              ),
              if (notifier.getExpanded(node.id) &&
                  node.childNodes.isNotEmpty) ...[
                // 与子节点之间连线
                SizedBox(
                  width: theme.spacingWithChild,
                  child: Divider(color: dividerColor),
                ),
                // 子节点区域
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(node.childNodes.length, (index) {
                    final childNode = node.childNodes[index];
                    return MindMap(childNode);
                  }),
                ),
              ],
            ],
          ),
        ),
        if (depth > 1)
          Positioned(
            top: 0,
            bottom: 0,
            width: 1,
            child: VerticalDivider(color: dividerColor),
          ),
      ],
    );
  }
}
