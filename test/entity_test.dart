import 'dart:io';

import 'package:cloudoc/cloudoc.dart';
import 'package:cloudoc/file_entity.dart';
import 'package:test/test.dart';

void main() {
  test('list entities', () {
    final l1 = listEntities(Directory('test/_test_/data'), 'test/_test_/static');

    expect(l1.length, 3);
    expect(l1.first.type, EntityType.folder);
    expect(l1.last.type, EntityType.doc);

    final l2 = listEntities(Directory('test/_test_/data/bar'), 'test/_test_/static');
    expect(l2.length, 1);
    final file3 = l2.first;
    expect(file3.size, 0);
    expect(file3.path, '/docx/file4.docx');
  });
}
