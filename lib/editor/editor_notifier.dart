import 'package:flutter/material.dart';
import 'package:mind_map_editor/editor/editor_state.dart';

class EditorNotifier extends ChangeNotifier {
  final tCntlr = TransformationController();
  final state = EditorState();

  void updateScale(_) {
    final scale = (tCntlr.value.getMaxScaleOnAxis() * 100).round();
    if (scale == state.scale) return;
    notifyListeners();
    state.scale = scale;
    state.scaling = true;
  }

  @override
  void dispose() {
    super.dispose();
    tCntlr.dispose();
  }

  void endScale(_) async {
    await Future.delayed(Durations.medium1);
    notifyListeners();
    state.scaling = false;
  }
}
