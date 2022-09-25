import 'dart:io' show HttpStatus;

import 'package:cloudoc/convert.dart' as c;
import 'package:cloudoc/file_entity.dart';
import 'package:cloudoc/model.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

class Service {
  final String authority;

  Service(this.authority);

  Future<List<FileEntity>> listEntities(String path) async {
    final res = await http.get(Uri.http(authority, 'api/$path'));
    if (res.statusCode == HttpStatus.ok) {
      final result = c.listBodyFrom<FileEntity>(res.body);
      return result.data;
    } else {
      throw Exception("Failed to fetch entities from '$path'");
    }
  }

  Future<List<FileEntity>> create(String path, String type) async {
    final res = await http.post(
      Uri.http(authority, 'api/create'),
      headers: const {
        "Content-Type": "application/json",
      },
      body: c.serialize(RequestBodyCreate(path: path, type: type)),
    );
    if (res.statusCode == HttpStatus.ok) {
      final result = c.listBodyFrom<FileEntity>(res.body);
      return result.data;
    } else {
      throw Exception("${res.statusCode}: Failed to create '$type' ${p.basename(path)}");
    }
  }

  Future<RemoteFile> upload(List<LocalFile> files, String remote) async {
    final url = Uri.http(authority, 'api/upload');
    final req = http.MultipartRequest("POST", url);
    req.files.addAll(files.map((f) => http.MultipartFile(
      remote,
      f.stream,
      f.size,
      filename: f.filename,
    )));
    final res = await req.send();
    if (res.statusCode == HttpStatus.ok) {
      final body = await res.stream.bytesToString();
      final files = c.listBodyFrom<RemoteFile>(body).data;
      return files.first;
    } else {
      throw Exception("Failed to upload '${files.map((e) => e.filename)
          .whereType<String>()}'(${res.statusCode})!}");
    }
  }
}
