import 'dart:io' show HttpStatus;

import 'package:cloudoc/convert.dart' as c;
import 'package:cloudoc/file_entity.dart';
import 'package:cloudoc/model.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

class Service {
  final String authority;

  Service(this.authority);

  static List<T> _bodyToItems<T>(http.BaseResponse res, String body, String errMsg) {
    final status = res.statusCode;
    if (status == HttpStatus.ok) {
      final Result<List<T>> result = c.listBodyFrom<T>(body);
      return result.data;
    } else {
      throw Exception('($status): $errMsg');
    }
  }

  Future<List<FileEntity>> listEntities(String path) async {
    final res = await http.get(Uri.http(authority, 'api/$path'));
    return _bodyToItems<FileEntity>(
      res,
      res.body,
      "Failed to fetch entities from '$path'",
    );
  }

  Future<List<FileEntity>> create(String path, String type) async {
    final res = await http.post(
      Uri.http(authority, 'api/create'),
      headers: const {
        "Content-Type": "application/json",
      },
      body: c.serialize(RequestBodyCreate(path: path, type: type)),
    );
    return _bodyToItems<FileEntity>(
      res,
      res.body,
      "Failed to create '$type' ${p.basename(path)}",
    );
  }

  Future<List<RemoteFile>> upload(List<LocalFile> files, String remote) async {
    final url = Uri.http(authority, 'api/upload');
    final req = http.MultipartRequest("POST", url);
    req.files.addAll(files.map((f) => http.MultipartFile(
      remote,
      f.stream,
      f.size,
      filename: f.filename,
    )));
    final res = await req.send();
    final list = _bodyToItems<RemoteFile>(
      res,
      await res.stream.bytesToString(),
      "Failed to upload '${files.map((e) => e.filename).whereType<String>()}'!}",
    );
    return list;
  }

  Future<List<FileEntity>> delete(String path, {bool? resolveLink}) async {
    if (path.startsWith("/")) {
      path = path.substring(1);
    }
    final url = Uri.http(authority, p.join('api/delete', path));
    final res = await http.delete(url);
    return _bodyToItems(
      res,
      res.body,
      "Failed to delete path '$path'",
    );
  }
}
