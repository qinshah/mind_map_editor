import 'dart:io';

import 'package:archive/archive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

abstract class FM {
  static late final Directory supportDir;

  static late final Directory tempDir;

  static final _zipDecoder = ZipDecoder();

  static final _zipEncoder = ZipEncoder();

  static final _archive = Archive();

  static final pathSeparator = Platform.pathSeparator;

  static Future<void> init() async {
    supportDir = await getApplicationSupportDirectory();
    tempDir = await getTemporaryDirectory();
  }

  static String tempPath(String path) {
    return '${tempDir.path}$pathSeparator$path';
  }

  static File tempPathFile(String path) {
    return File(tempPath(path));
  }

  static String supportPath(String path) {
    return '${supportDir.path}$pathSeparator$path';
  }

  static File supportPathFile(String path) {
    return File(supportPath(path));
  }

  static Future<void> encodeDirToArchive(
    String archivePath, {
    required String dirPath,
  }) async {
    final dir = Directory(dirPath);
    await _archive.clear();
    // 收集所有文件
    await for (final entity in dir.list(recursive: true)) {
      if (entity is! File) continue;
      final relativePath = relative(entity.path, from: dirPath);
      final bytes = await entity.readAsBytes();
      _archive.addFile(
        ArchiveFile(
          relativePath, // 落包路径
          bytes.length,
          bytes,
        ),
      );
    }
    final outputFile = File(archivePath);
    await outputFile.create(recursive: true);
    // 编码并写入
    final zipBytes = _zipEncoder.encode(_archive);
    await outputFile.writeAsBytes(zipBytes, flush: true);
  }

  static Future<void> decodeArchiveTo(
    String path, {
    required String archivePath,
  }) async {
    final archive = _zipDecoder.decodeBytes(
      await File(archivePath).readAsBytes(),
    );
    for (final entry in archive) {
      if (entry.isFile) {
        final file = File('$path$pathSeparator${entry.name}');
        await file.create(recursive: true);
        await file.writeAsBytes(entry.content);
      }
    }
  }
}

extension PathExtension on String {
  String join(List<String> subDirs) {
    String path = this;
    for (final subDir in subDirs) {
      path += '${FM.pathSeparator}$subDir';
    }
    return path;
  }
}
