import 'dart:convert' show json;

import 'package:shelf/shelf.dart' show Response;
import 'file_entity.dart';

class Result {
  final int code;
  final Object data;

  Result(this.code, this.data);

  String toJson() => json.encode({
    'code': code,
    'data': data,
  }, toEncodable: (e) {
    if (e is FileEntity) {
      return e.toJson();
    }
    return null;
  });

  static Response ok(Object data) => Response.ok(
    Result(0, data).toJson(),
    headers: {
      'Content-type':'application/json',
    }
  );
}

class RequestBodyCreate {
  final String path;
  final String type;

  const RequestBodyCreate({
    required this.path,
    required this.type,
  });

  factory RequestBodyCreate.fromJson(String str) {
    final obj = json.decode(str) as Map<String, dynamic>;
    return RequestBodyCreate(
      path: obj['path']!,
      type: obj['type']!,
    );
  }

  String toJson() => json.encode({
    'path': path,
    'type': type,
  });
}
