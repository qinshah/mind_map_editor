import 'package:flutter/material.dart';
import 'package:mind_map_editor/data_model/xmind.dart';
import 'package:mind_map_editor/module/mind_map/mind_map_state.dart';
import 'package:uuid/uuid.dart';

class MindMapCntlr extends ChangeNotifier {
  static const uuid = Uuid();
  MindMapState state = MindMapState();

  bool getExpanded(String id) => state.expandeds[id] ?? true;

  void toggleExpand(String id) {
    notifyListeners();
    state.expandeds[id] = !getExpanded(id);
  }

  bool getFocused(Node node) => state.focusedNode?.id == node.id;

  void foucsNode(Node? node) {
    notifyListeners();
    state.focusedNode = node;
  }

  void rebuild() => notifyListeners();

  // TODO：完善树节点的插入删除机制
  void deleteSelected() {
    final node = state.focusedNode;
    if (node == null || node.parent == null) return;
    node.parent!.subNodes.remove(node);
    foucsNode(null);
  }

  void insertSubNode(Node node) {
    node.children ??= Children(attached: []);
    final subNode = Node(
      id: uuid.v4(),
      image: null,
      title: '新节点',
      parent: node,
    );
    node.children!.attached.add(subNode);
    foucsNode(subNode);
  }

  void insertBrotherNode() {
    final node = state.focusedNode;
    if (node == null || node.parent == null) return;
    insertSubNode(node.parent!);
  }
}
