import 'dart:async';

import 'package:mind_map_editor/xmind/xmind.dart';

class EditorState {
  Xmind xmind = Xmind.empty();

  Xnode? focusedNode;

  Timer scalingTimer = Timer(Duration.zero, () {})..cancel();

  bool changedFlag = false;
  int zoom = 100;
  Timer transformingTimer = Timer(Duration.zero, () {})..cancel();
  bool editDialogShowing = false;
  bool interacting = false;
}
