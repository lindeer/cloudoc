import 'dart:convert' show json;
import 'dart:io' show HttpStatus;

import 'package:http/http.dart' as http;

import '../file_entity.dart';

class Service {
  final String authority;

  Service(this.authority);

  Future<List<FileEntity>> listEntities(String path) async {
    final res = await http.get(Uri.http(authority, 'api/$path'));
    if (res.statusCode == HttpStatus.ok) {
      final body = json.decode(res.body) as Map<String, dynamic>;
      final list = body['data'] as List<dynamic>;
      return list.map((e) {
        final map = e as Map<String, dynamic>;
        return FileEntity.fromJson(map);
      }).toList(growable: false);
    } else {
      throw Exception("Failed to fetch entities from '$path'");
    }
  }
}
