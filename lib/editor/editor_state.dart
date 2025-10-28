import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mind_map_editor/model/xmind.dart';

class EditorState {
  Xmind xmind = Xmind.empty();
  Timer scaleHubTimer = Timer(Duration.zero, () {})..cancel();

  int scale = 100;

  double width = 888;

  double height = 888;

  late Offset origin = Offset.zero;
}
