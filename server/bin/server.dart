
import 'package:cloudoc_server/api.dart' as api;
import 'package:cloudoc_server/src/serve_context.dart';
import 'package:cloudoc_server/view.dart' as view;
import 'package:shelf/shelf.dart' show Cascade, Pipeline, logRequests;
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:shelf_static/shelf_static.dart' show createStaticHandler;

const _dataRoot = '_root';
const _defaultPort = 8989;

void main(List<String> args) {
  String? dir;
  String? p;
  final it = args.iterator;
  while (it.moveNext()) {
    final opt = it.current;
    switch (opt) {
      case '-p':
      case '--port':
        it.moveNext();
        p = it.current;
        break;
      default:
        dir = opt;
    }
  }

  dir ??= _dataRoot;
  final context = ServeContext(
    root: '$dir/data',
    docServer: 'http://192.168.0.130',
  );

  api.serve(context);
  view.serve(context);

  final webHandler = createStaticHandler('$dir/web',
    defaultDocument: 'index.html',
  );

  final cascade = Cascade()
      .add(webHandler)
      .add(context.router);

  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsHeaders())
      .addHandler(cascade.handler);


  final port = p == null ? _defaultPort : (int.tryParse(p) ?? _defaultPort);
  io.serve(handler, '0.0.0.0', port).then((server) {
    print('start server at ${server.address.host}:${server.port} ...');
  });
}
