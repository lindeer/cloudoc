import 'dart:io';

import 'package:cloudoc/model.dart';
import 'package:cloudoc_client/client/service.dart';
import 'package:cloudoc/file_entity.dart';
import 'package:cloudoc_server/api.dart' as api;
import 'package:path/path.dart' as p;
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:test/test.dart';

void main() async {
  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addHandler(api.serve('test/_test_'));
  const port = 8964;
  final server = await io.serve(handler, '0.0.0.0', port);
  final service = Service('0.0.0.0:$port');

  const folder = 'new1';
  final d = Directory('test/_test_/desktop/$folder');
  if (d.existsSync()) {
    d.deleteSync();
  }
  final deletingFiles = <String>[];

  test('test list api', () async {
    final entities = await service.listEntities('desktop');
    expect(entities.length, 2);
    expect(entities.first.type, EntityType.folder);
    expect(entities.last.type, EntityType.sheet);
    expect(entities.last.name, 'foo.xlsx');
  });

  test('test entity type', () async {
    final entities = await service.listEntities('desktop/path/to/heart');
    expect(entities.length, 1);
    expect(entities.first.type, EntityType.unknown);
    expect(entities.first.name, 'heart.txt');
  });

  test('test create folder', () async {
    final entities = await service.create('desktop/$folder', 'folder');
    expect(entities.length, 3);
    final remote = entities.firstWhere((e) => e.name == folder);
    expect(remote.type, EntityType.folder);
  });

  test('test create folder', () async {
    final entities = await service.create('desktop/$folder', 'folder');
    expect(entities.length, 3);
    final remote = entities.firstWhere((e) => e.name == folder);
    expect(remote.type, EntityType.folder);
  });

  test('test upload file', () async {
    const filename = 'test_upload.xlsx';
    const serverDir = '/desktop/path/to';
    const localFile = 'test/_test_/$filename';
    const serverPath = '$serverDir/$filename';
    const serverPath2 = '$serverDir/test_upload(1).xlsx';
    deletingFiles.add('test/_test_$serverPath');
    deletingFiles.add('test/_test_$serverPath2');

    final f1 = File(localFile);
    List<RemoteFile> items = await service.upload(
      [LocalFile(filename: filename, size: f1.statSync().size, stream: f1.openRead())],
      serverDir,
    );
    final file = items.first;
    expect(file.path, serverPath);
    expect(FileSystemEntity.isLinkSync('test/_test_/$serverPath'), true);
    final link = File('test/_test_/$serverPath');
    final target = link.resolveSymbolicLinksSync();
    final local = File(localFile);
    expect(File(target).statSync().size, local.statSync().size);
    expect(p.dirname(target).endsWith('static/sheets'), true);

    items = await service.upload(
      [LocalFile(filename: filename, size: f1.statSync().size, stream: f1.openRead())],
      serverDir,
    );
    final file2 = items.first;
    expect(file2.path, serverPath2);
  });

  test('test delete directory', () async {
    const name = 'deleting-folder';
    final list1 = await service.create('/desktop/path/$name', 'folder');
    final created = list1.firstWhere((e) => e.name == name);
    expect(created.type, EntityType.folder);
    final list2 = await service.delete('/desktop/path/$name');
    final names = list2.map((e) => e.name);
    expect(names.contains(name), false);
  });

  test('test delete file', () async {
    const filename = '用于测试.xlsx';
    const serverDir = '/desktop/path';
    final f = File('test/_test_/test_upload.xlsx');
    final items = await service.upload(
      [LocalFile(filename: filename, size: f.statSync().size, stream: f.openRead())],
      serverDir,
    );
    final file = items.first;
    final entities = await service.delete(file.path);
    final names = entities.map((e) => e.name);
    expect(names.contains(filename), false);
    final ref = file.ref!;
    File('test/_test_/$ref').deleteSync();
  });

  tearDownAll(() {
    server.close(force: true);
    for (final path in deletingFiles) {
      final f = Link(path);
      try {
        final remote = File(f.resolveSymbolicLinksSync());
        remote.deleteSync();
      } on Exception catch (_) {
      }
      if (f.existsSync()) {
        f.deleteSync();
      }
    }
  });
}
