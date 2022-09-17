import 'dart:convert' show json;

import 'package:shelf/shelf.dart' show Response;
import 'file_entity.dart';

typedef JsonEncoder<T> = Map<String, dynamic> Function(T obj);
typedef JsonDecoder<T> = T Function(dynamic obj);

final _jsonConverters = <Type, JsonDecoder>{
  FileEntity: (dynamic obj) => FileEntity.fromJson(obj),
};

class Result<T> {
  final int code;
  final T data;

  Result(this.code, this.data);

  String toJson() => json.encode({
    'code': code,
    'data': data,
  }, toEncodable: (e) {
    try {
      return e.toJson();
    } on Error catch (_) {
      return null;
    }
  });

  static Result<List<E>> listFrom<E>(String str) {
    final body = json.decode(str) as Map<String, dynamic>;
    final list = body['data'] as List<dynamic>;
    final converter = _jsonConverters[E] as JsonDecoder<E>;
    final items = list.map(converter).toList(growable: false);
    return Result<List<E>>(
      body['code'] ?? -1,
      items,
    );
  }

  static Result<R> from<R>(String str) {
    final body = json.decode(str) as Map<String, dynamic>;
    final converter = _jsonConverters[R] as JsonDecoder<R>;
    final R obj = converter(body['data']);
    return Result<R>(
      body['code'] ?? -1,
      obj,
    );
  }

  static Response ok<R>(R data) => Response.ok(
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
