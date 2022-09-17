import 'package:cloudoc/client/service.dart';
import 'package:cloudoc/file_entity.dart';
import 'package:cloudoc/server/api.dart' as api;
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:test/test.dart';

void main() async {
  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addHandler(api.serve('test/_test_'));
  const port = 8964;
  await io.serve(handler, '0.0.0.0', port);
  final service = Service('0.0.0.0:$port');
  test('test list api', () async {
    final entities = await service.listEntities('desktop');
    expect(entities.length, 2);
    expect(entities.first.type, EntityType.folder);
    expect(entities.last.type, EntityType.sheet);
    expect(entities.last.name, 'foo.xlsx');
  });

  test('test entity type', () async {
    final entities = await service.listEntities('desktop/path/to/heart');
    expect(entities.length, 1);
    expect(entities.first.type, EntityType.unknown);
    expect(entities.first.name, 'heart.txt');
  });
}
