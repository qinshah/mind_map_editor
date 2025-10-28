import 'package:flutter/material.dart';
import 'package:mind_map_editor/data_model/mind_map_theme.dart';
import 'package:mind_map_editor/module/mind_map/mind_map_notifier.dart';
import 'package:mind_map_editor/module/mind_map/view/node_widget.dart';
import 'package:mind_map_editor/data_model/xmind.dart';
import 'package:provider/provider.dart';

class MindMap extends StatefulWidget {
  final Node curNode;
  const MindMap(this.curNode, {super.key});

  @override
  State<MindMap> createState() => _MindMapState();
}

class _MindMapState extends State<MindMap> {
  late final _curNode = widget.curNode;

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<MindMapNotifier>();
    final expanded = notifier.getExpanded(_curNode.id);
    final theme = _curNode.path.isEmpty
        ? MindMapTheme(
            spacingBetweenChild: 10,
            spacingBetweenParentAndChild: 40,
          )
        : MindMapTheme();
    return Row(
      children: [
        // 节点卡片
        NodeWidget(_curNode, onTap: () => notifier.toggleExpand(_curNode.id)),
        // 子节点区域
        if (expanded && _curNode.childNodes.isNotEmpty) ...[
          SizedBox(width: theme.spacingBetweenParentAndChild),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(_curNode.childNodes.length, (index) {
              final childNode = _curNode.childNodes[index];
              final key = ValueKey(childNode.id);
              if (index > 0) {
                return Padding(
                  padding: EdgeInsets.only(top: theme.spacingBetweenChild),
                  child: MindMap(childNode, key: key),
                );
              }
              return MindMap(childNode, key: key);
            }),
          ),
        ],
      ],
    );
  }
}
