import 'package:flutter/material.dart';
import 'package:mind_map_editor/model/xmind.dart';

class MindMap extends StatefulWidget {
  final Node root;
  const MindMap(this.root, {super.key});

  @override
  State<MindMap> createState() => _MindMapState();
}

class _MindMapState extends State<MindMap> {
  final Map<String, bool> _expanded = {}; // 折叠状态

  @override
  Widget build(BuildContext context) {
    return _buildNode(widget.root, 0);
  }

  /// 递归渲染节点
  Widget _buildNode(Node node, int depth) {
    final isExpanded = _expanded[node.id] ?? true;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 节点卡片
        _nodeCard(node, isExpanded),
        // 子节点区域
        if (isExpanded && node.childNodes.isNotEmpty) ...[
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: node.childNodes
                .map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: _buildNode(e, depth + 1),
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }

  /// 单个节点 UI
  Widget _nodeCard(Node node, bool isExpanded) {
    return GestureDetector(
      onTap: () => setState(() => _expanded[node.id] = !isExpanded),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors
              .primaries[node.hashCode % Colors.primaries.length]
              .shade900,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (node.childNodes.isNotEmpty)
              Icon(
                isExpanded ? Icons.expand_more : Icons.chevron_right,
                size: 16,
                color: Colors.blue,
              ),
            const SizedBox(width: 4),
            Text(node.title, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
