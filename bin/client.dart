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

  void _onClickAction(BuildContext context, EntityAction action) {
    switch (action) {
      case EntityAction.createFolder:
        _createFolder(context);
        break;
      case EntityAction.createDoc:
        break;
      case EntityAction.createSheet:
        break;
      case EntityAction.createSlide:
        break;
      case EntityAction.upload:
        break;
    }
  }

  void _createFolder(BuildContext context) async {
    final controller = TextEditingController();
    final folderName = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Create a new folder'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              prefixIcon: Icon(Icons.edit),
              hintText: 'Enter folder name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                final text = controller.text;
                Navigator.of(ctx).pop(text);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
    if (folderName != null && folderName.trim().isNotEmpty) {
      _model.createFolder(folderName.trim());
    }
  }

  static const _fileIcons = {
    EntityType.unknown: Icons.file_copy_outlined,
    EntityType.folder: Icons.folder_outlined,
    EntityType.doc: FontAwesome4.file_word,
    EntityType.sheet: FontAwesome4.file_excel,
    EntityType.slide: FontAwesome4.file_powerpoint,
  };

  Widget _buildEntityWidget(BuildContext context, FileEntity entity) {
    final icon = _fileIcons[entity.type] ?? Icons.file_copy_outlined;
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Colors.orange,),
        title: Text(entity.name),
        onTap: entity.type != EntityType.unknown
            ? () => _model.onEntityClicked(entity)
            : null,
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
        children: _createActionButtons(context),
      ),
    );
  }

  List<Widget> _createActionButtons(BuildContext context) {
    const icons = {
      EntityAction.createFolder: FontAwesome4.folder_create,
      EntityAction.createDoc: FontAwesome4.file_word,
      EntityAction.createSheet: FontAwesome4.file_excel,
      EntityAction.createSlide: FontAwesome4.file_powerpoint,
      EntityAction.upload: FontAwesome4.file_upload,
    };
    return icons.entries.map((e) {
      return ActionItemButton(
        onPressed: () => _onClickAction(context, e.key),
        icon: Icon(
          e.value,
          color: Colors.white,
        ),
      );
    }).toList(growable: false);
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
