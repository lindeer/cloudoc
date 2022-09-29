
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
  final String? ref;

  const RemoteFile(this.path, [this.ref]);

  RemoteFile.fromJson(dynamic obj): this(obj['path'], obj['ref']);

  Map<String, dynamic> get json => {
    'path': path,
    if (ref != null)
      'ref': ref,
  };
}

/// In client side, it is actual local file.
/// In server side, it is the representation of multi part file.
class LocalFile {
  final String filename;
  /// not necessary for server side, just set 0.
  final int size;
  final Stream<List<int>> stream;
  /// necessary for server side, it is the multiPart's name.
  final String? path;
  /// necessary for server side.
  final String? fid;

  const LocalFile({
    required this.filename,
    required this.size,
    required this.stream,
    this.path,
    this.fid,
  });

  String get fileId => fid ?? ('0' * 22);
}
