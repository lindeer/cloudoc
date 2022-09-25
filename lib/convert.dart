import 'dart:convert' show json;

import 'file_entity.dart';
import 'model.dart';

typedef JsonEncoder<T> = Map<String, dynamic> Function(T obj);
typedef JsonDecoder<T> = T Function(dynamic obj);

final _jsonConverters = <Type, JsonDecoder>{
  FileEntity: (dynamic obj) => FileEntity.fromJson(obj),
  RemoteFile: (dynamic obj) => RemoteFile.fromJson(obj),
  RequestBodyCreate: (dynamic obj) => RequestBodyCreate.fromJson(obj),
};

String serialize(dynamic obj) => json.encode(
  obj,
  toEncodable: (e) {
    try {
      return e.json;
    } on NoSuchMethodError catch (_) {
      print("Error: '${e.runtimeType}' has no property 'json'!");
      return null;
    }
  },
);

T deserialize<T>(String str) {
  final jsonObj = json.decode(str);
  return _decode(jsonObj);
}

T _decode<T>(dynamic jsonObj) {
  final converter = _jsonConverters[T] as JsonDecoder<T>;
  final T obj = converter(jsonObj);
  return obj;
}

Result<List<E>> listBodyFrom<E>(String str) {
  final body = json.decode(str) as Map<String, dynamic>;
  final list = body['data'] as List<dynamic>;
  final converter = _jsonConverters[E] as JsonDecoder<E>;
  final items = list.map(converter).toList(growable: false);
  return Result<List<E>>(
    items,
    code: body['code'] ?? -1,
  );
}

Result<R> bodyFrom<R>(String str) {
  final body = json.decode(str) as Map<String, dynamic>;
  final R obj = _decode(body['data']);
  return Result<R>(
    obj,
    code: body['code'] ?? -1,
  );
}
