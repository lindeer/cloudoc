
import 'dart:convert' show HtmlEscape;
import 'dart:io' show Directory, File, FileSystemEntity;
import 'package:path/path.dart' as p;

import 'file_entity.dart';

const _sanitizer = HtmlEscape();

List<FileEntity> listEntities(Directory dir, String refDir) {
  final items = dir.listSync(recursive: false);
  items.sort((e1, e2) {
    if (e1 is Directory && e2 is! Directory) {
      return -1;
    }
    if (e1 is! Directory && e2 is Directory) {
      return 1;
    }
    return e1.path.compareTo(e2.path);
  });

  final dirPath = dir.path;

  return items.map((e) {
    final refPath = e.resolveSymbolicLinksSync();
    final isDir = FileSystemEntity.isDirectorySync(refPath);
    final suffix = isDir ? '/' : '';
    final name = '${p.relative(e.path, from: dirPath)}$suffix';
    final sanitizedName = name;

    final file = FileSystemEntity.isFileSync(refPath) ? File(refPath)
        : isDir ? Directory(refPath)
        : null;
    if (file == null) return null;
    final stat = file.statSync();
    final path = FileSystemEntity.isLinkSync(e.path)
        ? '/${p.relative(file.path, from: refDir)}'
        : null;

    return FileEntity(
      name: sanitizedName,
      lastUpdated: stat.modified.millisecondsSinceEpoch,
      size: stat.size,
      isDirectory: isDir,
      path: path,
    );
  }).whereType<FileEntity>().toList(growable: false);
}
