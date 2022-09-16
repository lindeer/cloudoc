
import 'package:cloudoc/server/api.dart' as api;
import 'package:cloudoc/server/view.dart' as view;
import 'package:shelf/shelf.dart' show Cascade, Pipeline, logRequests;
import 'package:shelf/shelf_io.dart' as io;

const _dataRoot = 'test/_test_';
const _defaultPort = 8989;

void main(List<String> args) {
  final webRoot = args.isNotEmpty ? args[0] : 'build/web';
  final app = Cascade()
      .add(view.serve(webRoot))
      .add(api.serve(_dataRoot))
      .handler;

  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addHandler(app);

  final port = args.length > 1 ? (int.tryParse(args[1]) ?? _defaultPort) : _defaultPort;
  io.serve(handler, '0.0.0.0', port).then((server) {
    print('start server at ${server.address.host}:${server.port} ...');
  });
}
