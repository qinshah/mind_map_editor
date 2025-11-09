import 'package:flutter/material.dart';
import 'package:mind_map_editor/data_model/mind_map_node.dart';
import 'package:mind_map_editor/module/mind_map/mind_map_state.dart';

class MindMapCntlr<Node extends MindMapNode> extends ChangeNotifier {
  final _state = MindMapState<Node>();

  final ValueChanged<Node> onNodeChanged;

  final Node Function() newNodeBuilder;

  MindMapCntlr({required this.onNodeChanged, required this.newNodeBuilder});

  bool getExpanded(Node node) => _state.expandedById[node.id] ?? true;

  void toggleExpanded(Node node) {
    _state.expandedById[node.id] = !getExpanded(node);
    foucs(node);
  }

  bool getFocused(Node node) => _state.focusedNode?.id == node.id;

  Node? focusedNode() => _state.focusedNode;

  void foucs(Node? node) {
    notifyListeners();
    _state.focusedNode = node;
  }

  void rebuild(Node node) {
    notifyListeners();
    onNodeChanged(node);
  }

  Node? getParentNode(Node node) {
    final path = _state.pathById[node.id];
    if (path == null || path.isEmpty) return null;
    final parentPath = [...path]..removeLast();
    return _state.nodeByPath[parentPath.toString()];
  }

  void deleteNode(Node node) {
    final parent = getParentNode(node);
    if (parent == null) throw Exception('暂不允许删除没有父节点的节点');
    parent.subNodes.remove(node);
    _state.deleteNodeState(node);
    onNodeChanged(parent);
    foucs(parent);
  }

  void insertNodeUnder(Node node, {int? index}) {
    index ??= node.subNodes.length;
    final newNode = newNodeBuilder();
    // 手动提前保存路径防止UI更新不过来
    saveNodePath(newNode, [..._state.pathById[node.id]!, index]);
    node.subNodes.insert(index, newNode);
    onNodeChanged(node);
    foucs(newNode);
  }

  void insertNodeAfter(Node node) {
    final parent = getParentNode(node);
    if (parent == null) throw Exception('没有父节点的节点无法插入兄弟节点');
    final insertIndex = _state.pathById[node.id]!.last + 1;
    insertNodeUnder(parent, index: insertIndex);
  }

  void saveNodePath(node, List<int> path) => _state.saveNodePath(node, path);
}
