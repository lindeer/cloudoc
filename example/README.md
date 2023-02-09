
```
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
```

## Client side

code in `client/lib/main.dart`:

```dart
import 'package:cloudoc/file_entity.dart';
import 'package:cloudoc/model.dart' show LocalFile;

  void _uploadFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: false,
      withReadStream: true,
    );
    if (result != null) {
      await _model.uploadFile(result.files.map((f) {
        return LocalFile(
          filename: f.name,
          size: f.size,
          stream: f.readStream!,
        );
      }).toList(growable: false));
    }
  }
```

## Server side

code in `server/lib/api.dart`:

```dart
import 'package:cloudoc/cloudoc.dart';
import 'package:cloudoc/config.dart';
import 'package:cloudoc/convert.dart' as c;
import 'package:cloudoc/file_entity.dart';
import 'package:cloudoc/meta.dart';
import 'package:cloudoc/model.dart';

  final file = LocalFile(
    filename: form.filename ?? '',
    size: 0,
    stream: form.part,
    path: form.name,
    fid: fileId(),
  );
  final link = await writeStreamFile(file, root, (reason) {
    (msg ??= <String>[]).add(reason);
  });
```
