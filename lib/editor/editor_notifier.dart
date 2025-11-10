import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mind_map_editor/common/path_const.dart';
import 'package:mind_map_editor/common/function/file_manager.dart';
import 'package:mind_map_editor/editor/editor_state.dart';
import 'package:file_selector/file_selector.dart';
import 'package:mind_map_editor/xmind/xmind.dart';
import 'package:mind_map_editor/editor/my_t_cntlr.dart';
import 'package:share_plus/share_plus.dart';

class EditorNotifier extends ChangeNotifier {
  final state = EditorState();
  final tCntlr = MyTCntlr();

  EditorNotifier() {
    _loadSavedData();
    tCntlr.addListener(_onTransform);
  }

  @override
  void dispose() {
    super.dispose();
    tCntlr.dispose();
  }

  void setShowHub(bool value) {
    notifyListeners();
    state.showHub = value;
  }

  void _onTransform() {
    final scale = (tCntlr.getCurScale() * 100).round();
    if (scale == state.scale) return;
    // 重新计时
    state.scalingTimer.cancel();
    state.scalingTimer = Timer(
      const Duration(seconds: 1),
      () => notifyListeners(),
    );
    notifyListeners();
    state.scale = scale;
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
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
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
