
import 'dart:io' show Directory, FileSystemEntity, FileSystemEntityType;

import 'package:cloudoc/cloudoc.dart';
import 'package:cloudoc/server/model.dart';
import 'package:path/path.dart' as p;
import 'package:shelf/shelf.dart' show Handler, Request, Response;
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart' show Router;
import 'package:shelf_static/shelf_static.dart' show createStaticHandler;

const _staticDataDirectories = {
  'docs',
  'sheets',
  'slides',
  'files',
};

const _dataRoot = '_data';

Handler _createModelHandler(String name, String dir) {
  final rootDir = Directory(p.join(dir, name));
  final root = rootDir.resolveSymbolicLinksSync();

  return (Request req) {
    final r = req.change(path: name);
    final fsPath = p.join(root, r.url.path);
    final entityType = FileSystemEntity.typeSync(fsPath);
    if (entityType != FileSystemEntityType.directory) {
      return Response.notFound('Not Found: error type');
    }
    final entities = listEntities(Directory(fsPath), '$dir/static');
    return Result.ok(entities);
  };
}

void main(List<String> arguments) {
  final router = Router();
  for (final name in _staticDataDirectories) {
    final handler = createStaticHandler('$_dataRoot/static/$name');
    router.get('/$name/<path|.*>', (Request req, String path) {
      final r = req.change(path: name);
      return handler(r);
    });
  }

  router.get('/desktop', _createModelHandler('desktop', _dataRoot));
  router.get('/', (Request req) => Response.movedPermanently('/desktop'));

  io.serve(router, 'localhost', 8989).then((_) {
    print('start server at localhost:8989 ...');
  });
}
