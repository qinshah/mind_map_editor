import 'package:flutter/material.dart';
import 'package:mind_map_editor/mind_map/m_m_node.dart';
import 'package:mind_map_editor/mind_map/m_m_state.dart';

class MMCntlr<Node extends MMNode> extends ChangeNotifier {
  final _state = MMState<Node>();

  final ValueChanged<Node>? onMapChanged;

  MMCntlr({this.onMapChanged});

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

  Node? getParentNode(Node node) {
    final path = _state.pathById[node.id];
    if (path == null || path.isEmpty) return null;
    final parentPath = [...path]..removeLast();
    return _state.nodeByPath[parentPath.toString()];
  }

  Future<void> deleteNode(Node node) async {
    final parent = getParentNode(node);
    if (parent == null) throw Exception('暂不允许删除没有父节点的节点');
    final parentSubNodes = parent.subNodes as List<Node>;
    final lastIndex = parentSubNodes.length - 1;
    final index = _state.pathById[node.id]!.last;
    final Node nextFocus;
    if (index > 0) {
      nextFocus = parentSubNodes[index - 1];
    } else if (index < lastIndex) {
      nextFocus = parentSubNodes[index + 1];
    } else {
      nextFocus = parent;
    }
    foucs(nextFocus);
    parentSubNodes.remove(node);
    _state.deleteNodeState(node);
    onMapChanged?.call(parent);
  }

  void insertNodeUnder(Node node, {int? index, required Node newNode}) {
    index ??= node.subNodes.length;
    // 手动提前保存路径防止UI更新不过来
    saveNodePath(newNode, [..._state.pathById[node.id]!, index]);
    node.subNodes.insert(index, newNode);
    onMapChanged?.call(node);
    foucs(newNode);
  }

  void insertNodeAfter(Node node, {required Node newNode}) {
    final parent = getParentNode(node);
    if (parent == null) throw Exception('没有父节点的节点无法插入兄弟节点');
    final insertIndex = _state.pathById[node.id]!.last + 1;
    insertNodeUnder(parent, newNode: newNode, index: insertIndex);
  }

  void saveNodePath(node, List<int> path) => _state.saveNodePath(node, path);

  void rebuild() => notifyListeners();
}
