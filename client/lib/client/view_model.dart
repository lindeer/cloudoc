
import 'package:cloudoc/file_entity.dart';
import 'package:flutter/widgets.dart' show ValueNotifier;

import 'service.dart';

enum LoadingState {
  loading,
  done,
  error,
}

enum EntityAction {
  createFolder,
  createDoc,
  createSheet,
  createSlide,
  upload,
}

class FileBrowserModel {
  final _pathStack = <String>[];
  final _entities = <FileEntity>[];
  final loadingNotifier = ValueNotifier(LoadingState.loading);
  final pathChanged = ValueNotifier(0);
  final Service _service;
  String? _errorMsg;

  FileBrowserModel(this._service);

  String get path => _pathStack.join('/');

  /// length of stack
  int get depth => _pathStack.length;

  /// count of entities
  int get size => _entities.length;

  String? get errorMessage => _errorMsg;

  FileEntity operator[](int pos) => _entities[pos];

  void dispose() {
    loadingNotifier.dispose();
    pathChanged.dispose();
  }

  void enter(String entry) {
    _pathStack.add(entry);
    _onPathChange('enter');
  }

  void back() {
    _pathStack.removeLast();
    _onPathChange('back');
  }

  void _onPathChange(String reason) async {
    pathChanged.value++;
    final path = _pathStack.join('/');
    _onEntitiesChanged(() => _service.listEntities(path), reason: reason);
  }

  Future<bool> _onEntitiesChanged(Future<List<FileEntity>> Function() cb, {
    String? reason,
  }) async {
    loadingNotifier.value = LoadingState.loading;
    bool ok = true;
    try {
      final entities = await cb();
      _entities..clear()..addAll(entities);
      loadingNotifier.value = LoadingState.done;
      _errorMsg = null;
    } on Exception catch (e) {
      _errorMsg = e.toString();
      loadingNotifier.value = LoadingState.error;
      ok = false;
    }
    return ok;
  }

  void onEntityClicked(FileEntity entity) {
    switch (entity.type) {
      case EntityType.folder:
        enter(entity.name);
        break;
      default:
        break;
    }
  }

  Future<bool> createFolder(String name) async {
    final path = [..._pathStack, name].join('/');
    final ok = await _onEntitiesChanged(() => _service.create(path, "folder"), reason: 'create folder');
    return ok;
  }
}
