import 'package:flutter/widgets.dart';
import 'package:mind_map_editor/mind_map/m_m_node.dart';

class MMState<Node extends MMNode> {
  Map<String, bool> expandedById = {};
  Map<String, Size> sizeById = {};
  Map<String, Node> nodeByPath = {};
  Map<String, List<int>> pathById = {};

  Node? focusedNode;

  void saveNodePath(node, List<int> path) {
    nodeByPath[path.toString()] = node;
    pathById[node.id] = path;
  }

  void deleteNodeState(node) {
    final id = node.id;
    expandedById.remove(id);
    sizeById.remove(id);
    final path = pathById[id];
    pathById.remove(id);
    nodeByPath.remove(path.toString());
  }
}
