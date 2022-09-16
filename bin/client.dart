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
    );
  }
}

class _BrowserPage extends StatefulWidget {
  const _BrowserPage({Key? key,}) : super(key: key);

  @override
  State<_BrowserPage> createState() => _BrowserPageState();
}

class _BrowserPageState extends State<_BrowserPage> {
  final _pathStack = <String>[];
  final _entities = <FileEntity>[];
  final _title = ValueNotifier('');
  final _service = Service("0.0.0.0:8989");

  @override
  void initState() {
    super.initState();

    _enterFolder('desktop');
  }

  void _enterFolder(String entry) async {
    _pathStack.add(entry);
    _title.value = _pathStack.join('/');
    final entities = await _service.listEntities(_title.value);
    _entities..clear()..addAll(entities);
    setState(() {
    });
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
        title: ValueListenableBuilder<String>(
          valueListenable: _title,
          builder: (ctx, value, _) {
            return Text(value);
          },
        ),
      ),
      body: Center(
        child: FractionallySizedBox(
          widthFactor: 0.7,
          child: ListView.builder(
            itemCount: _entities.length,
            itemBuilder: (ctx, index) => _buildEntityWidget(ctx, _entities[index]),
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