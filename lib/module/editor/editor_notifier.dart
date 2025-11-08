import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mind_map_editor/data/const.dart';
import 'package:mind_map_editor/function/file_manager.dart';
import 'package:mind_map_editor/module/editor/editor_state.dart';
import 'package:file_selector/file_selector.dart';
import 'package:mind_map_editor/data_model/xmind.dart';
import 'package:share_plus/share_plus.dart';

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

  Future<void> import() async {
    final xFile = await openFile(
      acceptedTypeGroups: [
        XTypeGroup(extensions: ['xmind', 'mind']),
      ],
    );
    if (xFile == null) return;
    await FM.decodeArchiveTo(
      FM.supportPath(Const.xmindDirName),
      archivePath: xFile.path,
    );
    loadSavedMindMap();
  }

  Future<void> loadSavedMindMap() async {
    final jsonFile = FM.supportPathFile(
      Const.xmindDirName.join([Const.xmindContentFileName]),
    );
    final xmind = Xmind.fromJson(jsonDecode(await jsonFile.readAsString()));
    notifyListeners();
    state.xmind = xmind;
  }

  Future<void> export() async {
    final jsonFile = FM.supportPathFile(
      Const.xmindDirName.join([Const.xmindContentFileName]),
    );
    final json = jsonEncode(state.xmind.toJson());
    await jsonFile.writeAsString(json);
    final tempMindPath = FM.tempPath('${state.xmind.root.title}.mind');
    await FM.encodeDirToArchive(
      tempMindPath,
      dirPath: FM.supportPath(Const.xmindDirName),
    );
    Share.shareXFiles([XFile(tempMindPath)]);
  }

  Future<void> updateMindMapSize(Size value) async {
    await Future.delayed(Durations.medium1); // 防止build未结束就rebuild
    notifyListeners();
    state.mindMapSize = value;
  }
}
