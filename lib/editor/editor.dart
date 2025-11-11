import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mind_map_editor/common/path_const.dart';
import 'package:mind_map_editor/common/function/file_manager.dart';
import 'package:mind_map_editor/editor/editor_state.dart';
import 'package:file_selector/file_selector.dart';
import 'package:mind_map_editor/editor/widget/edit_dialog.dart';
import 'package:mind_map_editor/mind_map/m_m_cntlr.dart';
import 'package:mind_map_editor/xmind/xmind.dart';
import 'package:mind_map_editor/editor/my_t_cntlr.dart';
import 'package:share_plus/share_plus.dart';

class Editor extends ChangeNotifier {
  final state = EditorState();
  final tCntlr = MyTCntlr();
  late final mMCnltr = MMCntlr<Xnode>(onMapChanged: (_) => save());
  final BuildContext Function() getContext;
  final dataFile = FM.supportPathFile(
    PathConst.root.join([PathConst.dataName]),
  );

  Editor({required this.getContext});

  init() {
    _loadLocalData();
    tCntlr.addListener(_onTransform);
    HardwareKeyboard.instance.addHandler(onKeyEvent);
  }

  @override
  void dispose() {
    super.dispose();
    tCntlr.dispose();
    tCntlr.removeListener(_onTransform);
  }

  bool onKeyEvent(KeyEvent event) {
    final node = mMCnltr.focusedNode();
    if (node == null || event is! KeyDownEvent) return false;
    final shiftAndSpace =
        HardwareKeyboard.instance.isShiftPressed &&
        event.logicalKey == LogicalKeyboardKey.space;
    if (state.editDialogShowing) {
      if (shiftAndSpace) {
        Navigator.of(getContext()).pop();
        return true;
      }
      return false;
    }
    final parent = mMCnltr.getParentNode(node);
    switch (event.logicalKey) {
      case LogicalKeyboardKey.escape:
        mMCnltr.foucs(null);
        return true;
      case LogicalKeyboardKey.tab:
        mMCnltr.insertNodeUnder(node, newNode: Xnode.empty('新节点'));
        return true;
      case LogicalKeyboardKey.enter:
        parent == null
            ? mMCnltr.insertNodeUnder(node, newNode: Xnode.empty('新节点'))
            : mMCnltr.insertNodeAfter(node, newNode: Xnode.empty('新节点'));
        return true;
      case LogicalKeyboardKey.delete || LogicalKeyboardKey.backspace:
        if (parent == null) return false;
        mMCnltr.deleteNode(node);
        return true;
      default:
        if (shiftAndSpace) {
          showEditDialog(node, getContext());
          return true;
        }
        return false;
    }
  }

  void _setTransforming() {
    final wasTransforming = state.transformingTimer.isActive;
    state.transformingTimer.cancel();
    state.transformingTimer = Timer(Durations.short1, () {
      notifyListeners();
      // state.transformingTimer.isActive == false
    });
    if (!wasTransforming) {
      notifyListeners();
      // state.transformingTimer.isActive == true
    }
  }

  void _onTransform() {
    _setZoom();
    _setTransforming();
  }

  void _setZoom() {
    final zoom = (tCntlr.getCurScale() * 100).round();
    if (zoom == state.zoom) return;
    // 重新计时
    state.scalingTimer.cancel();
    notifyListeners();
    state.scalingTimer = Timer(const Duration(seconds: 1), () {
      notifyListeners();
      // state.scalingTimer.isActive == false
    });
    state.zoom = zoom;
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
    _loadLocalData();
  }

  Future<void> _loadLocalData() async {
    if (!await dataFile.exists()) {
      await dataFile.create(recursive: true);
      return;
    }
    final xmind = Xmind.fromJson(jsonDecode(await dataFile.readAsString()));
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
    final json = jsonEncode(state.xmind.toJson());
    await dataFile.writeAsString(json);
  }

  Future<void> showEditDialog(Xnode node, BuildContext context) async {
    if (state.editDialogShowing) {
      print('重复显示，请检查是否为Bug');
    }
    state.editDialogShowing = true;
    await showDialog(context: context, builder: (_) => EditDialog(node));
    state.editDialogShowing = false;
    save();
    mMCnltr.rebuild();
  }
}
