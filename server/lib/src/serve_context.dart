
import 'package:shelf_router/shelf_router.dart' show Router;

class ServeContext {
  /// root of data directory
  final String root;
  final Router router = Router();

  ServeContext({
    required this.root,
  });
}
