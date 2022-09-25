
class Result<T> {
  final int code;
  final T data;

  Result(this.data, {this.code = 0});

  Map<String, dynamic> get json => {
    'code': code,
    'data': data,
  };
}

class RequestBodyCreate {
  final String path;
  final String type;

  const RequestBodyCreate({
    required this.path,
    required this.type,
  });

  RequestBodyCreate.fromJson(dynamic obj): this(
    path: obj['path']!,
    type: obj['type']!,
  );

  Map<String, dynamic> get json => {
    'path': path,
    'type': type,
  };
}

class RemoteFile {
  final String path;

  const RemoteFile(this.path);

  RemoteFile.fromJson(dynamic obj): this(obj['path']);

  Map<String, dynamic> get json => {
    'path': path,
  };
}
