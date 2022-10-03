import 'package:cloudoc/user.dart';
import 'package:shelf/shelf.dart' show Request;

final _self = User(
  id: 'uid-0',
  name: 'Wesley Chang',
  email: 'le.chang118@gmail.com',
);

extension RequestExt on Request {
  User get user {
    return _self;
  }
}
