import 'dart:io';

import 'package:any_base/any_base.dart' show AnyBase;
import 'package:uuid/uuid.dart' show Uuid;

const _flickrBase58 = '123456789abcdefghijkmnopqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ';
const _anyBase = AnyBase(AnyBase.hex, _flickrBase58);

String fileId() {
  final uuid = Uuid().v4().toLowerCase().replaceAll('-', '');
  final id = _anyBase.convert(uuid);
  return id.padLeft(22, '0');
}

String generateDocKey(String filePath, String fileUrl) {
  final stat = File(filePath).statSync();
  final h = '${fileUrl}_${stat.modified.microsecondsSinceEpoch}'.hashCode.toString();
  return h.length > 20 ? h.substring(0, 20) : h;
}
