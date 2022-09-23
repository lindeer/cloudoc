import 'dart:io' show HttpStatus;

import 'package:path/path.dart' as p;
import 'package:http/http.dart' as http;

import '../file_entity.dart';
import '../model.dart';

class Service {
  final String authority;

  Service(this.authority);

  Future<List<FileEntity>> listEntities(String path) async {
    final res = await http.get(Uri.http(authority, 'api/$path'));
    if (res.statusCode == HttpStatus.ok) {
      final result = Result.listFrom<FileEntity>(res.body);
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
      body: RequestBodyCreate(path: path, type: type).toJson(),
    );
    if (res.statusCode == HttpStatus.ok) {
      final result = Result.listFrom<FileEntity>(res.body);
      return result.data;
    } else {
      throw Exception("Failed to create '$type' ${p.basename(path)}");
    }
  }

  Future<RemoteFile> upload(String filepath, String remote) async {
    final url = Uri.http(authority, 'api/upload');
    final req = http.MultipartRequest("POST", url);
    final part = await http.MultipartFile.fromPath(
      remote,
      filepath,
      filename: p.basename(filepath),
    );

    req.files.add(part);
    final res = await req.send();
    if (res.statusCode == HttpStatus.ok) {
      final body = await res.stream.bytesToString();
      final files = Result.listFrom<RemoteFile>(body).data;
      return files.first;
    } else {
      throw Exception("Failed to upload '$filepath'(${res.statusCode})!}");
    }
  }
}
