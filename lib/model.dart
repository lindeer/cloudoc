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
