import 'dart:io' show Directory, File, FileSystemEntity, FileSystemEntityType;

import 'package:cloudoc/cloudoc.dart';
import 'package:cloudoc/config.dart';
import 'package:cloudoc/convert.dart' as c;
import 'package:cloudoc/file_entity.dart';
import 'package:cloudoc/meta.dart';
import 'package:cloudoc/model.dart';
import 'package:path/path.dart' as p;
import 'package:shelf/shelf.dart' show Handler, Request, Response;
import 'package:shelf_multipart/form_data.dart' show ReadFormData;
import 'package:shelf_static/shelf_static.dart';

import 'file_id.dart';
import 'src/ext.dart';
import 'src/serve_context.dart';

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

Handler _createModelHandler(String name, String dir) {
  final rootDir = Directory(p.join(dir, name));
  if (!rootDir.existsSync()) {
    rootDir.createSync(recursive: true);
  }
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

Handler serve(ServeContext context) {
  final root = context.root;
  final router = context.router;
  for (final name in staticDocDirectories) {
    final dir = '$root/static/$name';
    if (!FileSystemEntity.isDirectorySync(dir)) {
      Directory(dir).createSync(recursive: true);
    }
  }
  final handler = createStaticHandler('$root/static');
  router.get('/static/<path|.*>', (Request req, String path) {
    final r = req.change(path: 'static');
    return handler(r);
  });

  router.get('/api/desktop<path|.*>', _createModelHandler('desktop', root));

  // TODO: create api as GET
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
    final meta = Meta(root);
    final files = <RemoteFile>[];
    final user = req.user;
    await for (final form in req.multipartFormData) {
      final file = LocalFile(
        filename: form.filename ?? '',
        size: 0,
        stream: form.part,
        path: form.name,
        fid: fileId(),
      );
      final link = await writeStreamFile(file, root, (reason) {
        (msg ??= <String>[]).add(reason);
      });
      final actual = link.resolveSymbolicLinksSync();
      final filename = p.basename(link.path);
      files.add(RemoteFile(p.join(form.name, filename), p.relative(actual, from: root)));
      meta.create(file.fileId, user);
    }

    return msg != null ? Result(msg, code: 1).response(400) : Result(files).ok;
  });

  router.delete('/api/delete<path|.*>', (Request req, String path) {
    if (path.startsWith('/')) {
      path = path.substring(1);
    }
    final fsPath = p.join(root, Uri.decodeComponent(path));
    final type = FileSystemEntity.typeSync(fsPath, followLinks: false);
    if (type == FileSystemEntityType.notFound) {
      return Response.notFound("path '$path' not found!");
    }
    Directory parent;
    if (type == FileSystemEntityType.directory) {
      final d = Directory(fsPath);
      parent = d.parent;
      d.deleteSync(recursive: true);
    } else {
      final f = File(fsPath);
      parent = f.parent;
      f.deleteSync(recursive: true);
    }
    final entities = listEntities(parent, root);
    return Result(entities).ok;
  });
  return router;
}
