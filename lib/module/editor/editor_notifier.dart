import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mind_map_editor/data/path_const.dart';
import 'package:mind_map_editor/function/file_manager.dart';
import 'package:mind_map_editor/module/editor/editor_state.dart';
import 'package:file_selector/file_selector.dart';
import 'package:mind_map_editor/data_model/xmind.dart';
import 'package:mind_map_editor/module/editor/my_t_cntlr.dart';
import 'package:share_plus/share_plus.dart';

class EditorNotifier extends ChangeNotifier {
  final state = EditorState();
  final tCntlr = MyTCntlr();

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
      FM.supportPath(PathConst.root),
      archivePath: xFile.path,
    );
    loadSavedMindMap();
  }

  Future<void> loadSavedMindMap() async {
    final jsonFile = FM.supportPathFile(
      PathConst.root.join([PathConst.dataName]),
    );
    final xmind = Xmind.fromJson(jsonDecode(await jsonFile.readAsString()));
    notifyListeners();
    state.xmind = xmind;
  }

  Future<void> export() async {
    await save();
    final tempMindPath = FM.tempPath('导出.mind');
    await FM.encodeDirToArchive(
      tempMindPath,
      dirPath: FM.supportPath(PathConst.root),
    );
    Share.shareXFiles([XFile(tempMindPath)]);
  }

  void updateMapSize(Size value) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
      state.mapSize = value;
    });
  }

  Future<void> save() async {
    final jsonFile = FM.supportPathFile(
      PathConst.root.join([PathConst.dataName]),
    );
    final json = jsonEncode(state.xmind.toJson());
    await jsonFile.writeAsString(json);
  }
}
