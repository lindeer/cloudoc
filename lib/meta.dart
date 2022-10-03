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

    File(file).writeAsStringSync(json.encode({
      'created': now,
      'uid': user.id,
      'uname': user.name,
    }));
    return file;
  }

  static String get now {
    final t = DateTime.now();
    return '${t.year}-${t.month.pad}-${t.day.pad} ${t.hour.pad}:${t.minute.pad}:${t.second.pad}';
  }

  Map<String, dynamic>? from(String fid) {
    final dir = p.join(_root, historyDir, fid);
    final file = p.join(dir, 'createdInfo.json');
    final f = File(file);
    if (!f.existsSync()) {
      return null;
    }
    return json.decode(f.readAsStringSync());
  }

  int version(String fid) {
    final dir = p.join(_root, historyDir, fid);
    if (!FileSystemEntity.isDirectorySync(dir)) {
      return 0;
    }
    final items = Directory(dir).listSync();
    final ver = items.map((e) => FileSystemEntity.isDirectorySync(e.path) ? 1 : 0)
        .reduce((v, e) => v + e);
    return ver + 1;
  }

  String _pathOfChanges(String fid, String ver) {
    return p.join(_root, historyDir, fid, ver, 'changes.json');
  }

  String _historyUri(String baseUrl, String fid, String ver, String file) {
    return '$baseUrl/downloadhistory?fid=$fid&ver=$ver&file=$file';
  }

  Map<String, dynamic> history(String baseUrl, String docKey, String path, String downloadUri, int ver) {
    try {
      return _retrieveHistory(baseUrl, docKey, path, downloadUri, ver);
    } on Exception catch (_) {
      return {};
    }
  }

  Map<String, dynamic> _retrieveHistory(String baseUrl, String docKey, String path, String docUrl, int version) {
    final fid = p.basenameWithoutExtension(path);
    final ext = p.extension(path).replaceAll('.', '');
    final hist = <Map<String, dynamic>>[];
    final histData = <String, dynamic>{};
    for (int v = 1; v <= version; v++) {
      final verDir = p.join(_root, historyDir, fid, '$v');
      final key = v == version ? docKey : File(p.join(verDir, 'key.txt')).readAsStringSync();
      final obj = {
        'key': key,
        'version': v,
      };
      final data = {
        'fileType': ext,
        'key': key,
        'version': v,
      };
      if (v == 1) {
        final meta = from(fid);
        if (meta != null) {
          obj.addAll({
            'created': meta['created'],
            'user': {
              'id': meta['uid'],
              'name': meta['uname']
            },
          });
        }
      }
      data['url'] = v == version ? docUrl : _historyUri(baseUrl, fid, '$v', 'prev$ext');
      final preVer = '${v - 1}';
      if (v > 1) {
        final changes = json.decode(File(_pathOfChanges(fid, preVer)).readAsStringSync());
        final change = changes?['changes'][0];
        if (change != null) {
          obj.addAll({
            'changes': changes?['changes'],
            'serverVersion': changes?['serverVersion'],
            'created': changes?['created'],
            'user': changes?['user'],
          });
        }
        final prev = histData['${v - 2}'];
        data['previous'] = {
          'fileType': prev['fileType'],
          'key': prev['key'],
          'url': prev['url'],
        };
        data['changesUrl'] = _historyUri(baseUrl, fid, preVer, 'diff.zip');
      }
      hist.add(obj);
      histData[preVer] = data;
    }
    return {
      'history': {
        'currentVersion': version,
        'history': hist,
      },
      'historyData': histData,
    };
  }
}
