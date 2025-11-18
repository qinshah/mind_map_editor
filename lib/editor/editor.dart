import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graphview/GraphView.dart';
import 'package:mind_map_editor/common/path_const.dart';
import 'package:mind_map_editor/common/function/file_manager.dart';
import 'package:mind_map_editor/editor/editor_state.dart';
import 'package:file_selector/file_selector.dart';
import 'package:mind_map_editor/editor/widget/edit_dialog.dart';
import 'package:mind_map_editor/xmind/xmind.dart';
import 'package:mind_map_editor/editor/my_t_cntlr.dart';
import 'package:share_plus/share_plus.dart';

class Editor extends ChangeNotifier {
  final state = EditorState();
  final tCntlr = MyTCntlr(minScale: 0.01, maxScale: 10);
  Graph graph = Graph()..isTree = true;
  late final graphCnltr = GraphViewController(transformationController: tCntlr);
  final BuildContext Function() getContext;
  final dataFile = FM.supportPathFile(
    PathConst.root.join([PathConst.dataName]),
  );

  Editor({required this.getContext});

  init() async {
    tCntlr.addListener(_onTransform);
    HardwareKeyboard.instance.addHandler(onKeyEvent);
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
    graph = Graph()..isTree = true;
    _addTree(xmind.root, []);
  }

  void _addTree(Xnode root, List<int> path) {
    root.path = path;
    for (int i = 0; i < root.subNodes.length; i++) {
      final subNode = root.subNodes[i];
      subNode.parent = root;
      graph.addEdge(root, subNode);
      _addTree(subNode, [...path, i]);
    }
  }

  @override
  void dispose() {
    super.dispose();
    tCntlr.dispose();
    tCntlr.removeListener(_onTransform);
  }

  bool onKeyEvent(KeyEvent event) {
    return false;
    // final node = mMCnltr.focusedNode();
    // if (node == null || event is! KeyDownEvent) return false;
    // final shiftAndSpace =
    //     HardwareKeyboard.instance.isShiftPressed &&
    //     event.logicalKey == LogicalKeyboardKey.space;
    // if (state.editDialogShowing) {
    //   if (shiftAndSpace) {
    //     Navigator.of(getContext()).pop();
    //     return true;
    //   }
    //   return false;
    // }
    // final parent = mMCnltr.getParentNode(node);
    // switch (event.logicalKey) {
    //   case LogicalKeyboardKey.escape:
    //     mMCnltr.foucs(null);
    //     return true;
    //   case LogicalKeyboardKey.tab:
    //     mMCnltr.insertNodeUnder(node, newNode: Xnode.empty('新节点'));
    //     return true;
    //   case LogicalKeyboardKey.enter:
    //     parent == null
    //         ? mMCnltr.insertNodeUnder(node, newNode: Xnode.empty('新节点'))
    //         : mMCnltr.insertNodeAfter(node, newNode: Xnode.empty('新节点'));
    //     return true;
    //   case LogicalKeyboardKey.delete || LogicalKeyboardKey.backspace:
    //     if (parent == null) return false;
    //     mMCnltr.deleteNode(node);
    //     return true;
    //   default:
    //     if (shiftAndSpace) {
    //       showEditDialog(node, getContext());
    //       return true;
    //     }
    //     return false;
    // }
  }

  void _onTransform() {
    _setZoom();
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

  Future<void> export() async {
    await _save();
    final tempMindPath = FM.tempPath('导出.mind');
    await FM.encodeDirToArchive(
      tempMindPath,
      dirPath: FM.supportPath(PathConst.root),
    );
    Share.shareXFiles([XFile(tempMindPath)]);
  }

  Future<void> _save() async {
    final json = jsonEncode(state.xmind.toJson());
    await dataFile.writeAsString(json);
  }

  Future<void> showEditDialog(Xnode node, BuildContext context) async {
    if (state.editDialogShowing) {
      debugPrint('重复显示，请检查是否为Bug');
    }
    final oldTitle = node.title;
    state.editDialogShowing = true;
    await showDialog(context: context, builder: (_) => EditDialog(node));
    state.editDialogShowing = false;
    if (node.title == oldTitle) return;
    _save();
    notifyListeners();
    state.changedFlag = !state.changedFlag;
  }

  void focus(Xnode node) {
    notifyListeners();
    state.focusedNode = node;
  }

  void toggleExpanded(Xnode node) {
    graphCnltr.toggleNodeExpanded(graph, node, animate: true);
    focus(node);
  }

  void insertNodeUnder(Xnode node, {required Xnode newNode}) {
    newNode.parent = node;
    newNode.path = [...node.path, node.subNodes.length];
    node.subNodes.add(newNode);
    _save();
    graph.addEdge(node, newNode);
    focus(newNode);
    state.changedFlag = !state.changedFlag;
  }

  void deleteSubNode(Xnode node, {required Xnode parent}) {
    parent.subNodes.remove(node);
    _save();
    graph.removeNode(node);
    focus(parent);
    state.changedFlag = !state.changedFlag;
  }
}
