import 'package:cloudoc/client/service.dart';
import 'package:cloudoc/file_entity.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const _FileExplorer());
}

class _FileExplorer extends StatelessWidget {
  const _FileExplorer({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final iconTheme = IconTheme.of(context);
    return MaterialApp(
      title: 'My Document Center',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        iconTheme: iconTheme.copyWith(color: Colors.orange),
      ),
      home: const _BrowserPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class _BrowserPage extends StatefulWidget {
  const _BrowserPage({Key? key,}) : super(key: key);

  @override
  State<_BrowserPage> createState() => _BrowserPageState();
}

enum _LoadingState {
  loading,
  done,
  error,
}

class _BrowserPageState extends State<_BrowserPage> {
  final _pathStack = <String>[];
  final _entities = <FileEntity>[];
  final _loadingNotifier = ValueNotifier(_LoadingState.loading);
  final _pathChanged = ValueNotifier(0);
  final _service = Service("0.0.0.0:8989");

  @override
  void initState() {
    super.initState();

    _enterFolder('desktop');
  }

  void _enterFolder(String entry) {
    _pathStack.add(entry);
    _onPathChange();
  }

  void _back() {
    _pathStack.removeLast();
    _onPathChange();
  }

  void _onPathChange() async {
    _pathChanged.value++;
    final path = _pathStack.join('/');
    _loadingNotifier.value = _LoadingState.loading;
    try {
      final entities = await _service.listEntities(path);
      _entities..clear()..addAll(entities);
      _loadingNotifier.value = _LoadingState.done;
    } on Exception catch (_) {
      _loadingNotifier.value = _LoadingState.error;
    }
  }

  void _onNewMenu() {
  }

  void _onClickItem(FileEntity entity) {
    _enterFolder(entity.name);
  }

  Widget _buildEntityWidget(BuildContext context, FileEntity entity) {
    final icon = entity.isDirectory ? Icons.folder : Icons.file_copy_outlined;
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Colors.orange,),
        title: Text(entity.name),
        onTap: entity.isDirectory ? () => _onClickItem(entity) : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: ValueListenableBuilder<int>(
          valueListenable: _pathChanged,
          builder: (ctx, value, _) {
            return Text('/${_pathStack.join('/')}');
          },
        ),
        leading: ValueListenableBuilder<int>(
          valueListenable: _pathChanged,
          builder: (ctx, value, child) {
            final canBack = _pathStack.length > 1;
            return IconButton(
              icon: child!,
              onPressed: canBack ? _back : null,
            );
          },
          child: const Icon(Icons.arrow_back),
        ),
      ),
      body: Center(
        child: FractionallySizedBox(
          widthFactor: 0.7,
          child: ValueListenableBuilder<_LoadingState>(
            valueListenable: _loadingNotifier,
            builder: (ctx, value, _) {
              switch (value) {
                case _LoadingState.error:
                  return ErrorWidget.withDetails(
                    message: 'load failed!',
                  );
                case _LoadingState.loading:
                  return Container(
                    width: 56,
                    height: 56,
                    child: CircularProgressIndicator(),
                  );
                default:
                  break;
              }
              return ListView.builder(
                itemCount: _entities.length,
                itemBuilder: (ctx, index) => _buildEntityWidget(ctx, _entities[index]),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onNewMenu,
        tooltip: 'Increment',
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
