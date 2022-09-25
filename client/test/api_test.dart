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
    final file = await service.upload(
      [LocalFile(filename, f1.statSync().size, f1.openRead())],
      serverDir,
    );
    expect(file.path, serverPath);
    expect(FileSystemEntity.isLinkSync('test/_test_/$serverPath'), true);
    final link = File('test/_test_/$serverPath');
    final target = link.resolveSymbolicLinksSync();
    final local = File(localFile);
    expect(File(target).statSync().size, local.statSync().size);
    expect(p.dirname(target).endsWith('static/sheets'), true);

    final file2 = await service.upload(
      [LocalFile(filename, f1.statSync().size, f1.openRead())],
      serverDir,
    );
    expect(file2.path, serverPath2);
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
