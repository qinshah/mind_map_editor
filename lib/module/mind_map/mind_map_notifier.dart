import 'package:flutter/material.dart';
import 'package:mind_map_editor/data_model/xmind.dart';
import 'package:mind_map_editor/module/mind_map/mind_map_state.dart';

class MindMapNotifier extends ChangeNotifier {
  MindMapState state = MindMapState();

  bool getExpanded(String id) => state.expandeds[id] ?? true;

  void toggleExpand(String id) {
    notifyListeners();
    state.expandeds[id] = !getExpanded(id);
  }

  bool getFocused(Node node) => node.id == state.focusedId;

  void foucsNode(Node node) {
    notifyListeners();
    state.focusedId = node.id;
    state.editingId = null;
  }

  bool getEditing(Node node) => node.id == state.editingId;

  void editNode(Node node) {
    notifyListeners();
    state.editingId = node.id;
  }

  void saveSelection(TextSelection selection, Node node) {
    state.selection = selection;
    state.selectionId = node.id;
  }
}
