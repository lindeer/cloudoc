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
    return MaterialApp(
      title: 'My Document Center',
      theme: ThemeData(
        primarySwatch: Colors.orange,
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

  void _onNewMenu() {
  }

  Widget _buildEntityWidget(BuildContext context, FileEntity entity) {
    return ListTile(
      title: Text(entity.name),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_pathStack.join('/')),
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
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
