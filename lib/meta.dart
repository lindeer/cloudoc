import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'config.dart';
import 'user.dart';

extension _IntExt on int {
  String get pad => toString().padLeft(2, '0');
}

class Meta {
  final String _root;

  Meta(this._root);

  String create(String fid, User user) {
    final dir = p.join(_root, historyDir, fid);
    final file = p.join(dir, 'createdInfo.json');
    final d = Directory(dir);
    if (!d.existsSync()) {
      d.createSync(recursive: true);
    }

    final t = DateTime.now();
    File(file).writeAsStringSync(json.encode({
      'created': '${t.year}-${t.month.pad}-${t.day.pad} ${t.hour.pad}:${t.minute.pad}:${t.second.pad}',
      'uid': user.id,
      'uname': user.name,
    }));
    return file;
  }
}
