import 'package:flutter/material.dart';
import 'package:mind_map_editor/module/mind_map/mind_map_state.dart';

class MindMapNotifier extends ChangeNotifier {
  MindMapState state = MindMapState();

  bool getExpanded(String id) => state.expandeds[id] ?? true;

  void toggleExpand(String id) {
    notifyListeners();
    state.expandeds[id] = !getExpanded(id);
  }
}
