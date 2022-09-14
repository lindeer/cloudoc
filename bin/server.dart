
import 'package:cloudoc/server/api.dart' as api;
import 'package:shelf/shelf.dart' show Pipeline, logRequests;
import 'package:shelf/shelf_io.dart' as io;

const _dataRoot = 'test/_test_';

void main(List<String> args) {
  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addHandler(api.compose(_dataRoot));
  io.serve(handler, 'localhost', 8989).then((_) {
    print('start server at localhost:8989 ...');
  });
}
