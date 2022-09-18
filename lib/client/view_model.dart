
import 'package:flutter/widgets.dart' show ValueNotifier;

import '../file_entity.dart';
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

  void enter(String entry) {
    _pathStack.add(entry);
    _onPathChange();
  }

  void back() {
    _pathStack.removeLast();
    _onPathChange();
  }

  void _onPathChange() async {
    pathChanged.value++;
    final path = _pathStack.join('/');
    loadingNotifier.value = LoadingState.loading;
    try {
      final entities = await _service.listEntities(path);
      _entities..clear()..addAll(entities);
      loadingNotifier.value = LoadingState.done;
      _errorMsg = null;
    } on Exception catch (e) {
      _errorMsg = e.toString();
      loadingNotifier.value = LoadingState.error;
    }
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

  void createFolder(String name) async {
  }
}
