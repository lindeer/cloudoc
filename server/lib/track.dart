import 'dart:convert' show json;
import 'dart:io' show Directory, File;

import 'package:cloudoc/config.dart';
import 'package:cloudoc/meta.dart';
import 'package:path/path.dart' as p;
import 'package:http/http.dart' as http;

class Tracker {
  final String _root;
  final Meta _meta;

  const Tracker(this._root, this._meta);

  Future<http.Response> commandRequest(String url, String method, String key) {
    final payload = {
      'c': method,
      'key': key,
    };
    final res = http.post(Uri.parse(url), body: json.encode(payload), headers: {
      'accept': 'application/json',
    });
    return res;
  }

  void save(Map<String, dynamic> body, Map<String, String> params) {
    final download = body['url'];
    if (download == null) {
      throw Exception('DownloadUrl is null');
    }
    final file = params['file'] ?? '';
    final fid = p.basenameWithoutExtension(file);
    final changesUri = body['changesurl'];
    final ext = p.extension(file);
    final fileType = body['filetype'];
    final downloadExt = fileType != null ? '.$fileType' : p.extension(download);
    if (ext != downloadExt) {
    }
    final dir = Directory(p.join(_root, historyDir, fid));
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    final ver = _meta.version(fid);
    final verDir = p.join(_root, historyDir, fid, '$ver');
    final d = Directory(verDir);
    if (!d.existsSync()) {
      d.createSync(recursive: true);
    }
    final prev = p.join(verDir, 'prev$ext');
    final localFile = p.join(_root, file);
    // move original file to prev
    // TODO: copySync -> renameSync
    File(localFile).copySync(prev);
    // download remote changed file into original file
    _saveUri(download, localFile);
    _saveUri(changesUri, p.join(verDir, 'diff.zip'));

    final hist = body['changeshistory'] ?? body['history'];
    if (hist != null) {
      File(p.join(verDir, 'changes.json')).writeAsStringSync(json.encode(hist));
    }
    File(p.join(verDir, 'key.txt')).writeAsStringSync(body['key']);
  }

  void forceSave(Map<String, dynamic> body, Map<String, String> params) {

  }

  void _saveUri(String url, String file) {

  }
}
