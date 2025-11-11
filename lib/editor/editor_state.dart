import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mind_map_editor/xmind/xmind.dart';

class EditorState {
  Xmind xmind = Xmind.empty();
  Timer scalingTimer = Timer(Duration.zero, () {})..cancel();

  int zoom = 100;
  bool transforming = false;
  bool editDialogShowing = false;

  Size mapSize = Size.zero;
}
