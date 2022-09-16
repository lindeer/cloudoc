import 'package:shelf/shelf.dart' show Handler;
import 'package:shelf_static/shelf_static.dart';

Handler serve(String dir) => createStaticHandler(dir, defaultDocument: 'index.html');
