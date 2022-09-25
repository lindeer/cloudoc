import 'package:any_base/any_base.dart' show AnyBase;
import 'package:uuid/uuid.dart' show Uuid;

const _flickrBase58 = '123456789abcdefghijkmnopqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ';
const _anyBase = AnyBase(AnyBase.hex, _flickrBase58);

String fileId() {
  final uuid = Uuid().v4().toLowerCase().replaceAll('-', '');
  final id = _anyBase.convert(uuid);
  return id.padLeft(22, '0');
}
