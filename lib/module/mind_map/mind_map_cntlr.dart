import 'package:flutter/material.dart';
import 'package:mind_map_editor/data_model/xmind.dart';
import 'package:mind_map_editor/module/mind_map/mind_map_state.dart';
import 'package:uuid/uuid.dart';

class MindMapCntlr extends ChangeNotifier {
  static const uuid = Uuid();
  MindMapState state = MindMapState();

  final ValueChanged<Node> onNodeChanged;

  MindMapCntlr({required this.onNodeChanged});

  bool getExpanded(String id) => state.expandeds[id] ?? true;

  void toggleExpand(Node node) {
    state.expandeds[node.id] = !getExpanded(node.id);
    foucs(node);
  }

  bool getFocused(Node node) => state.focusedNode?.id == node.id;

  void foucs(Node? node) {
    notifyListeners();
    state.focusedNode = node;
  }

  void rebuild(Node node) {
    notifyListeners();
    onNodeChanged(node);
  }

  // TODO：完善树节点的插入删除机制
  void deleteNode(Node node) {
    assert(node.parent != null, '根节点不能删除');
    node.parent!.subNodes.remove(node);
    onNodeChanged(node.parent!);
    foucs(node.parent!);
  }

  void insertNodeUnder(Node node) {
    node.children ??= Children(attached: []);
    final subNode = Node(
      id: uuid.v4(),
      image: null,
      title: '新节点',
      parent: node,
    );
    node.children!.attached.add(subNode);
    onNodeChanged(node);
    foucs(subNode);
  }

  void insertNodeAfter(Node node) {
    assert(node.parent != null, '根节点不能插入兄弟节点');
    insertNodeUnder(node.parent!);
  }
}
