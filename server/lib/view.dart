import 'dart:convert' show json;
import 'dart:io' show File, FileSystemEntity, FileSystemEntityType;

import 'package:cloudoc/config.dart';
import 'package:cloudoc/meta.dart';
import 'package:cloudoc_server/file_id.dart';
import 'package:path/path.dart' as p;
import 'package:shelf/shelf.dart' show Handler, Request, Response;

import 'src/ext.dart';
import 'src/serve_context.dart';
import 'src/template_editor.dart' as editor;

Response _html(String html) {
  return Response.ok(html, headers: {
    'content-type': 'text/html; charset=utf-8',
  });
}

String _serverUrl(Request req) {
  final uri = req.requestedUri;
  return req.headers['x-forwarded-proto'] ?? '${uri.scheme}://${uri.authority}';
}

Handler serve(ServeContext context) {
  final root = context.root;
  final router = context.router;

  router.get('/edit', (Request req) {
    final params = req.requestedUri.queryParameters;
    String file = params['file'] ?? '';
    final fsPath = p.join(root, file);
    final type = FileSystemEntity.typeSync(fsPath, followLinks: true);
    if (type == FileSystemEntityType.notFound) {
      return Response.notFound("file '$file' not found!");
    }
    final baseUrl = _serverUrl(req);
    final fileUri = '$baseUrl/$file';
    final filename = p.basename(file);
    final fid = p.basenameWithoutExtension(file);
    final ext = p.extension(filename).replaceFirst('.', '');
    final actualPath = File(fsPath).resolveSymbolicLinksSync();
    final path = p.relative(actualPath, from: root);
    final downloadUri = '$baseUrl/$path';
    final docKey = generateDocKey(actualPath, fileUri);
    final fileType = fileTypes[ext] ?? 'word';
    final user = req.user;

    String edMode = params['mode'] ?? 'edit';
    bool canEdit = fileDirectories.keys.contains(ext);
    if (((!canEdit && edMode == 'edit') || edMode == 'fillForms') && fillFormsDocs.contains(ext)) {
      edMode = 'fillForms';
      canEdit = true;
    }
    final submitForm =  edMode == 'fillForms';
    final mode = canEdit && edMode != 'view' ? 'edit' : 'view';
    final typeParam = params['type'];
    final edType = webTypes.contains(typeParam) ? typeParam! : 'desktop';
    final lang = params['ulang'] ?? 'zh';

    final mt = Meta(root);
    final meta = mt.from(fid);
    final anchorData = params['actionLink'];
    final anchor = anchorData == null ? null : json.decode(anchorData);
    final createUrl = '$baseUrl/create';
    /*
    final image = fileImages[fileType] ?? 'file_docx.svg';
    final imageUrl = '$baseUrl/assets/images/$image';
    final templates = [
      {
        'image': '',
        'title': 'Blank',
        'url': createUrl
      },
      {
        'image': imageUrl,
        'title': 'With sample content',
        'url': '$createUrl&sample=true'
      },
    ];
    */

    final info = meta != null ? <String, dynamic>{
      'owner': meta['uname'],
      'uploaded': meta['created']
    } : <String, dynamic>{
      'owner': 'Me',
      'uploaded': Meta.now,
    };
    info['favorite'] = false;
    final edConfig = {
      'type': edType,
      'documentType': fileType,
      'document': {
        'title': filename,
        'url': downloadUri,
        'fileType': ext,
        'key': docKey,
        'info': info,
        'permissions': {
          'comment': (edMode != 'view') & (edMode != 'fillForms') & (edMode != 'embedded') & (edMode != "blockcontent"),
          'copy': true, // 'copy' not in user.deniedPermissions,
          'download': true,
          'edit': canEdit & ((edMode == 'edit') | (edMode == 'view') | (edMode == 'filter') | (edMode == "blockcontent")),
          'print': true,
          'fillForms': (edMode != 'view') & (edMode != 'comment') & (edMode != 'embedded') & (edMode != "blockcontent"),
          'modifyFilter': edMode != 'filter',
          'modifyContentControl': edMode != "blockcontent",
          'review': canEdit & ((edMode == 'edit') | (edMode == 'review')),
          'reviewGroups': ['group-2'],
          'commentGroups': {
            'view': ['group-2'],
            'edit': ['group-2'],
            'remove': []
          },
          'userInfoGroups': ['group-2'],
        },
      },
      'editorConfig': {
        'actionLink': anchor,
        'mode': mode,
        'lang': lang,
        // TODO: callback url
        //'callbackUrl': docManager.getCallbackUrl(filename, request),
        'createUrl': createUrl,
        // 'templates': templates,
        'user': {
          'id': user.id,
          'name': user.name,
          'group': 'group-2',
        },
        'embedded': {
          'saveUrl': downloadUri,
          'embedUrl': downloadUri,
          'shareUrl': downloadUri,
          'toolbarDocked': 'top',
        },
        'customization': {
          'about': true,
          'comments': true,
          'feedback': true,
          'forcesave': false,
          'submitForm': submitForm,
          'goback': {
            'url': baseUrl,
          }
        },
      },
    };
    final dataInsertImage = json.encode({
      'fileType': 'png',
      'url': '$baseUrl/assets/images/logo.png',
    });
    final dataCompareFile = {
      'fileType': 'docx',
      'url': '$baseUrl/assets/static/sample.docx',
    };
    final dataMailMergeRecipients = {
      'fileType': 'csv',
      'url': '$baseUrl/csv',
    };
    final usersForMentions = <Map<String, String>>[];
    final version = mt.version(fid);
    final hist = version == 0 ? const <String, dynamic>{}
        : mt.history(baseUrl, docKey, path, downloadUri, version);
    return _html(editor.render({
      'cfg': json.encode(edConfig),
      if (hist.containsKey('history'))
        'history': hist['history'],
      if (hist.containsKey('historyData'))
        'historyData': hist['historyData'],
      'fileType': fileType,
      'apiUrl': context.docApi,
      'dataInsertImage': dataInsertImage.substring(1, dataInsertImage.length - 1),
      'dataCompareFile': json.encode(dataCompareFile),
      'dataMailMergeRecipients': json.encode(dataMailMergeRecipients),
      'usersForMentions': json.encode(usersForMentions),
    }));
  });

  return router;
}
