import 'dart:async';
import 'dart:convert';

import 'package:archive/archive_io.dart';
import 'package:flutter/material.dart';
import 'package:mind_map_editor/editor/editor_state.dart';
import 'package:file_selector/file_selector.dart';
import 'package:mind_map_editor/model/xmind.dart';

class EditorNotifier extends ChangeNotifier {
  final state = EditorState();
  final tCntlr = TransformationController();

  void updateScale(_) {
    final scale = (tCntlr.value.getMaxScaleOnAxis() * 100).round();
    if (scale == state.scale) return;
    // 重新计时
    state.scaleHubTimer.cancel();
    state.scaleHubTimer = Timer(
      const Duration(seconds: 2),
      () => notifyListeners(),
    );
    notifyListeners();
    state.scale = scale;
  }

  @override
  void dispose() {
    super.dispose();
    tCntlr.dispose();
  }

  Future<void> importXmind() async {
    final xFile = await openFile(
      acceptedTypeGroups: [
        XTypeGroup(extensions: <String>['xmind']),
      ],
    );
    if (xFile == null) return;
    final archive = ZipDecoder().decodeBytes(await xFile.readAsBytes());
    final jsonFile = archive.findFile('content.json');
    if (jsonFile == null || !jsonFile.isFile) return;
    notifyListeners();
    state.xmind = Xmind.fromJson(jsonDecode(utf8.decode(jsonFile.content)));
  }

  Future<void> updateMindMapSize(Size value) async {
    await Future.delayed(Durations.medium1); // 防止build未结束就rebuild
    notifyListeners();
    state.mindMapSize = value;
  }
}
