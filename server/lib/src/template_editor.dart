
import 'dart:io' show Platform;

import 'package:jinja/jinja.dart' show Environment;
import 'package:jinja/loaders.dart' show FileSystemLoader;
import 'package:path/path.dart' as p;

// final packageUri = Uri.parse('package:markdown/markdown.dart');
final packageDir = p.normalize(p.join(p.dirname(Platform.script.path), '..'));

final _env = Environment(
  loader: FileSystemLoader(
    paths: [
      p.join(packageDir, 'res', 'templates'),
    ],
  ),
  filters: <String, Function>{
    'safe': (f) => f,
    'dump': (f) => f,
    'resolveAsset': (f) {
      return '/res/$f';
    },
  },
);

String render(Map<String, dynamic> data) {
  return _env.getTemplate('editor.html').render(data);
}
