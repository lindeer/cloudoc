
import 'package:shelf_router/shelf_router.dart' show Router;

class ServeContext {
  /// root of data directory
  final String root;
  final String docServer;
  final Router router = Router();

  ServeContext({
    required this.root,
    required this.docServer,
  });

  String get docApi => '$docServer/web-apps/apps/api/documents/api.js';

  String get commandApi => '$docServer/coauthoring/CommandService.ashx';
}
