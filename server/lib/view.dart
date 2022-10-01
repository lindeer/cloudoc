import 'dart:io' show FileSystemEntity, FileSystemEntityType;

import 'package:path/path.dart' as p;
import 'package:shelf/shelf.dart' show Handler, Request, Response;

import 'src/serve_context.dart';
import 'src/template_editor.dart' as editor;

Response _html(String html) {
  return Response.ok(html, headers: {
    'content-type': 'text/html; charset=utf-8',
  });
}

Handler serve(ServeContext context) {
  final root = context.root;
  final router = context.router;

  router.get('/edit', (Request req) {
    final params = req.requestedUri.queryParameters;
    String file = params['file'] ?? '';
    final fsPath = p.join(root, file);
    final type = FileSystemEntity.typeSync(fsPath, followLinks: true);
    if (type == FileSystemEntityType.notFound) {
      return Response.notFound("file '$file' not found!");
    }
    return _html(editor.render({
    }));
  });

  return router;
}
