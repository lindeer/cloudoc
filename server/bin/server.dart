
import 'package:cloudoc_server/api.dart' as api;
import 'package:cloudoc_server/src/serve_context.dart';
import 'package:cloudoc_server/view.dart' as view;
import 'package:shelf/shelf.dart' show Pipeline, logRequests;
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_cors_headers/shelf_cors_headers.dart';

const _dataRoot = '_data';
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

  final context = ServeContext(
    root: dir ?? _dataRoot,
  );

  api.serve(context);
  view.serve(context);

  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsHeaders())
      .addHandler(context.router);

  final port = p == null ? _defaultPort : (int.tryParse(p) ?? _defaultPort);
  io.serve(handler, '0.0.0.0', port).then((server) {
    print('start server at ${server.address.host}:${server.port} ...');
  });
}
