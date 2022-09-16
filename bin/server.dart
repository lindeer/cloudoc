
import 'package:cloudoc/server/api.dart' as api;
import 'package:shelf/shelf.dart' show Pipeline, logRequests;
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_cors_headers/shelf_cors_headers.dart';

const _dataRoot = 'test/_test_';
const _defaultPort = 8989;

void main(List<String> args) {

  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsHeaders())
      .addHandler(api.serve(_dataRoot));

  final port = args.isNotEmpty ? (int.tryParse(args[0]) ?? _defaultPort) : _defaultPort;
  io.serve(handler, '0.0.0.0', port).then((server) {
    print('start server at ${server.address.host}:${server.port} ...');
  });
}
