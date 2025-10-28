import 'package:flutter/material.dart';
import 'package:mind_map_editor/editor/view/mind_map_node.dart';
import 'package:mind_map_editor/model/xmind.dart';

class MindMap extends StatefulWidget {
  final Node curNode;
  final bool initExpand;
  const MindMap(this.curNode, {super.key, this.initExpand = true});

  @override
  State<MindMap> createState() => _MindMapState();
}

class _MindMapState extends State<MindMap> {
  late bool _expanded = widget.initExpand;
  late final _curNode = widget.curNode;

  @override
  Widget build(BuildContext context) {
    /// 递归渲染节点
    return Row(
      children: [
        // 节点卡片
        MindMapNode(
          _curNode,
          onTap: () => setState(() => _expanded = !_expanded),
        ),
        // 子节点区域
        if (_expanded && _curNode.childNodes.isNotEmpty) ...[
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(_curNode.childNodes.length, (index) {
              if (index > 0) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: MindMap(_curNode.childNodes[index]),
                );
              }
              return MindMap(_curNode.childNodes[index]);
            }),
          ),
        ],
      ],
    );
  }
}
