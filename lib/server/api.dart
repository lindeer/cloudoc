
import 'dart:io' show Directory, FileSystemEntity, FileSystemEntityType;

import 'package:path/path.dart' as p;
import 'package:shelf/shelf.dart' show Handler, Request, Response;
import 'package:shelf_multipart/form_data.dart' show ReadFormData;
import 'package:shelf_router/shelf_router.dart' show Router;
import 'package:shelf_static/shelf_static.dart';

import '../cloudoc.dart';
import '../file_entity.dart';
import '../model.dart';
import '../convert.dart' as c;

extension ResultExt<T> on Result<T> {

  Response response(int httpCode) => Response(
    httpCode,
    body: c.serialize(this),
    headers: {
      'Content-type':'application/json',
    },
  );

  Response get ok => response(200);
}

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
    return Result(entities).ok;
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

  router.post('/api/create', (Request req) async {
    final reqBean = c.deserialize<RequestBodyCreate>(await req.readAsString());
    String parent = p.dirname(reqBean.path);
    if (parent.startsWith('/')) {
      parent = parent.substring(1);
    }
    final fsDir = p.join(root, parent);
    if (!FileSystemEntity.isDirectorySync(fsDir)) {
      return Response.badRequest(body: "path '$parent' is not directory!");
    }
    final type = FileEntity.of(reqBean.type);
    if (type == EntityType.folder) {
      Directory(p.join(fsDir, p.basename(reqBean.path))).createSync();
      final entities = listEntities(Directory(fsDir), root);
      return Result(entities).ok;
    }
    return Response.badRequest(body: "type '$type' is illegal!");
  });

  router.post('/api/upload', (Request req) async {
    if (!req.isMultipartForm) {
      return Response(406, body: 'support only multipart form');
    }
    List<String>? msg;
    final files = <RemoteFile>[];
    await for (final form in req.multipartFormData) {
      final file = FileInfo(
        form.name,
        form.filename ?? '',
        form.part,
      );
      final link = await writeStreamFile(file, root, (reason) {
        (msg ??= <String>[]).add(reason);
      });
      final filename = p.basename(link.path);
      files.add(RemoteFile(p.join(form.name, filename)));
    }

    return msg != null ? Result(msg, code: 1).response(400) : Result(files).ok;
  });
  return router;
}
