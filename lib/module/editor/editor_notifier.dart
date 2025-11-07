import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:flutter/material.dart';
import 'package:mind_map_editor/module/editor/editor_state.dart';
import 'package:file_selector/file_selector.dart';
import 'package:mind_map_editor/data_model/xmind.dart';
import 'package:path_provider/path_provider.dart';
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
    final archive = ZipDecoder().decodeBytes(await xFile.readAsBytes());
    final jsonFile = archive.findFile('content.json');
    if (jsonFile == null || !jsonFile.isFile) return;
    notifyListeners();
    state.xmind = Xmind.fromJson(jsonDecode(utf8.decode(jsonFile.content)));
  }

  Future<void> share(Xmind xmind, {String fileName = '导出.mind'}) async {
    /* 1. 打成 zip 字节 */
    final archive = Archive()
      ..addFile(
        ArchiveFile(
          'content.json',
          utf8.encode(jsonEncode(xmind.toJson())).length,
          utf8.encode(jsonEncode(xmind.toJson())),
        ),
      );
    final bytes = ZipEncoder().encode(archive);

    /* 2. 写到临时目录 */
    final tmp = await getTemporaryDirectory();
    final tmpFile = File('${tmp.path}/$fileName');
    await tmpFile.writeAsBytes(bytes, flush: true);

    /* 3. 分享 */
    await Share.shareXFiles([XFile(tmpFile.path)], subject: '思维导图');
  }

  Future<void> updateMindMapSize(Size value) async {
    await Future.delayed(Durations.medium1); // 防止build未结束就rebuild
    notifyListeners();
    state.mindMapSize = value;
  }
}
