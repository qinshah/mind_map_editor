import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mind_map_editor/data_model/xmind.dart';

class EditorState {
  Xmind xmind = Xmind.empty();
  Timer scaleHubTimer = Timer(Duration.zero, () {})..cancel();

  int scale = 100;

  late Offset origin = Offset.zero;

  Size mindMapSize = Size.zero;

  final minScale = 0.2;

  final maxScale = 5.0;
}
