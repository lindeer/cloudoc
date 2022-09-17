
import 'dart:io' show Directory, FileSystemEntity, FileSystemEntityType;

import 'package:path/path.dart' as p;
import 'package:shelf/shelf.dart' show Handler, Request, Response;
import 'package:shelf_router/shelf_router.dart' show Router;
import 'package:shelf_static/shelf_static.dart';

import '../cloudoc.dart';
import '../model.dart';

const _staticDataDirectories = {
  'docs',
  'sheets',
  'slides',
  'files',
};

Handler _createModelHandler(String name, String dir) {
  final rootDir = Directory(p.join(dir, name));
  final root = rootDir.resolveSymbolicLinksSync();

  return (Request req) {
    final r = req.change(path: 'api/$name');
    final fsPath = p.join(root, r.url.path);
    final entityType = FileSystemEntity.typeSync(fsPath);
    switch (entityType) {
      case FileSystemEntityType.directory: break;
      case FileSystemEntityType.notFound:
        return Response.notFound('Not Found: "${req.url.path}"');
      default:
        return Response.badRequest(body: 'Bad Request: "${req.url.path}"');
    }
    final entities = listEntities(Directory(fsPath), '$dir/static');
    return Result.ok(entities);
  };
}

Handler serve(String root) {
  final router = Router();
  for (final name in _staticDataDirectories) {
    final handler = createStaticHandler('$root/static/$name');
    router.get('/$name/<path|.*>', (Request req, String path) {
      final r = req.change(path: name);
      return handler(r);
    });
  }

  router.get('/api/desktop<path|.*>', _createModelHandler('desktop', root));
  return router;
}
