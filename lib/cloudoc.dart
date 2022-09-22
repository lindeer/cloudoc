
import 'dart:io' show
                    Directory,
                    File,
                    FileStat,
                    FileSystemEntity,
                    FileSystemEntityType;
import 'package:path/path.dart' as p;

import 'file_entity.dart';

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
    final name = p.relative(e.path, from: dirPath);
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
      type: isDir ? EntityType.folder : _guessFileType(name, stat),
      path: path,
    );
  }).whereType<FileEntity>().toList(growable: false);
}

EntityType _guessFileType(String filename, FileStat stat) {
  int pos = filename.lastIndexOf('.');
  final ext = pos < 0 ? null : filename.substring(pos + 1);
  switch (ext) {
    case 'doc':
    case 'docx':
      return EntityType.doc;
    case 'xls':
    case 'xlsx':
      return EntityType.sheet;
    case 'ppt':
    case 'pptx':
      return EntityType.slide;
  }
  return EntityType.unknown;
}

class FileInfo {
  final String name;
  final String filename;
  final Stream<List<int>> stream;

  const FileInfo(this.name, this.filename, this.stream);
}

Future<void> writeStreamFile(
    FileInfo file,
    String root,
    void Function(String reason) onError,) async {
  final name = file.name;
  final path = name.startsWith('/') ? name.substring(1) : name;
  final dir = p.join(root, path);
  if (!Directory(dir).existsSync()) {
    onError("Directory '$name' not exists!");
  }
  final filename = file.filename;
  final basename = p.basenameWithoutExtension(filename);
  final ext = p.extension(filename);
  String filepath = p.join(dir, filename);
  int n = 1;
  while (FileSystemEntity.typeSync(filepath) != FileSystemEntityType.notFound) {
    filepath = p.join(dir, '$basename(${n++})$ext');
  }
  final sink = File(filepath).openWrite();
  await sink.addStream(file.stream);
  await sink.close();
}
