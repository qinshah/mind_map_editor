import 'package:mind_map_editor/data_model/xmind.dart';

class MindMapState {
  Map<String, bool> expandeds = {};
  Map<String, bool> sizes = {};

  Node? focusedNode;
}
