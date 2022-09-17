import 'package:cloudoc/client/expand_fab.dart';
import 'package:cloudoc/client/service.dart';
import 'package:cloudoc/client/view_model.dart';
import 'package:cloudoc/file_entity.dart';
import 'package:cloudoc/client/font_awesome4_icons.dart';
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

class _BrowserPageState extends State<_BrowserPage> {
  final _model = FileBrowserModel(Service("0.0.0.0:8989"));
  late final ValueNotifier<int> _pathChanged;
  late final ValueNotifier<LoadingState> _loadingNotifier;
  @override
  void initState() {
    super.initState();

    _pathChanged = _model.pathChanged;
    _loadingNotifier = _model.loadingNotifier;
    _model.enter('desktop');
  }

  Widget _buildEntityWidget(BuildContext context, FileEntity entity) {
    final icon = entity.isDirectory ? Icons.folder : Icons.file_copy_outlined;
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Colors.orange,),
        title: Text(entity.name),
        onTap: entity.isDirectory ? () => _model.onEntityClicked(entity) : null,
      ),
    );
  }

  void _onClickAction(BuildContext context, int position) {
    print("_onClickAction: $position");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: ValueListenableBuilder<int>(
          valueListenable: _pathChanged,
          builder: (ctx, value, _) {
            return Text('/${_model.path}');
          },
        ),
        leading: ValueListenableBuilder<int>(
          valueListenable: _pathChanged,
          builder: (ctx, value, child) {
            final canBack = _model.depth > 1;
            return IconButton(
              icon: child!,
              onPressed: canBack ? _model.back : null,
            );
          },
          child: const Icon(Icons.arrow_back),
        ),
      ),
      body: Center(
        child: _makeBody(context),
      ),
      floatingActionButton: ExpandFab(
        distance: 140.0,
        children: List<Widget>.generate(_menus.length, (i) {
          return ActionItemButton(
            onPressed: () => _onClickAction(context, i),
            icon: Icon(
              _menus[i],
              color: Colors.white,
            ),
          );
        }),
      ),
    );
  }

  Widget _makeBody(BuildContext context) {
    return ValueListenableBuilder<LoadingState>(
      valueListenable: _loadingNotifier,
      child: const SizedBox(
        width: 56,
        height: 56,
        child: CircularProgressIndicator(),
      ),
      builder: (ctx, value, child) {
        switch (value) {
          case LoadingState.error:
            return ErrorWidget.withDetails(
              message: 'load failed!',
            );
          case LoadingState.loading:
            return child!;
          default:
            break;
        }
        final size = _model.size;
        if (size == 0) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(
                Icons.add_circle,
                size: 56,
              ),
              Text('Press add button to create new files'),
            ],
          );
        }
        return FractionallySizedBox(
          widthFactor: 0.7,
          child: ListView.builder(
            itemCount: size,
            itemBuilder: (ctx, index) => _buildEntityWidget(ctx, _model[index]),
          ),
        );
      },
    );
  }
}

const _menus = [
  FontAwesome4.folder_create,
  FontAwesome4.file_word,
  FontAwesome4.file_excel,
  FontAwesome4.file_powerpoint,
  FontAwesome4.file_upload,
];
