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
  Node get rootNode => widget.rootNode;

  @override
  Widget build(BuildContext context) {
    final dividerColor = Theme.of(context).colorScheme.onSurface;
    final notifier = context.watch<MindMapNotifier>();
    final depth = rootNode.path.length;
    final theme = depth == 1
        // 根节点
        ? MindMapTheme(spacingBetweenChild: 20, spacingWithChild: 40)
        : depth == 2
        // 根节点的子节点
        ? MindMapTheme(spacingBetweenChild: 10, spacingWithChild: 30)
        // 后面的节点
        : MindMapTheme();
    return Container(
      color: Colors.primaries[rootNode.hashCode % Colors.primaries.length]
          .withAlpha(50),
      child: Row(
        children: [
          // 根节点卡片
          NodeWidget(
            key: Key(rootNode.id),
            rootNode,
            onTap: () => notifier.toggleExpand(rootNode.id),
          ),
          if (notifier.getExpanded(rootNode.id) &&
              rootNode.childNodes.isNotEmpty) ...[
            // 根节点与子节点间的左半区域
            // 绘制从根节点出发的横线
            SizedBox(
              width: theme.spacingWithChild / 2,
              child: Divider(color: dividerColor),
            ),
            Stack(
              children: [
                VerticalDivider(color: dividerColor),
                // 所有子树
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(rootNode.childNodes.length, (index) {
                    final childNode = rootNode.childNodes[index];
                    return Padding(
                      padding: index == 0
                          ? EdgeInsets.zero
                          // 该子节点与前一个子节点之间
                          : EdgeInsets.only(top: theme.spacingBetweenChild),
                      child: Row(
                        children: [
                          // 根节点与子节点间的右半区域
                          // 绘制到子节点的横线
                          SizedBox(
                            width: theme.spacingWithChild / 2,
                            child: Divider(color: dividerColor),
                          ),
                          MindMap(childNode),
                        ],
                      ),
                    );
                  }),
                ),
                // 根节点与子节点之间的中间位置，绘制竖线
                Positioned(
                  top: 0,
                  bottom: 0,
                  width: 1,
                  child: VerticalDivider(color: dividerColor),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
