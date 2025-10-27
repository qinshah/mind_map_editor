import 'package:flutter/material.dart';
import 'package:mind_map_editor/editor/editor_state.dart';
import 'package:mind_map_editor/editor/view/editor_hub.dart';

class EditorView extends StatefulWidget {
  const EditorView({super.key});

  @override
  State<EditorView> createState() => _EditorViewState();
}

class _EditorViewState extends State<EditorView> {
  final _state = EditorState();
  final _cntlr = TransformationController();
  late ThemeData _theme;

  void _updateScale(ScaleUpdateDetails details) {
    final scale = (_cntlr.value.getMaxScaleOnAxis() * 100).round();
    if (scale == _state.scale) return;
    setState(() {
      _state.scale = scale;
      _state.scaling = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    _theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(toolbarHeight: 0),
      body: Stack(
        children: [
          InteractiveViewer.builder(
            onInteractionUpdate: _updateScale,
            onInteractionEnd: (_) async {
              await Future.delayed(Durations.medium1);
              setState(() => _state.scaling = false);
            },
            transformationController: _cntlr,
            minScale: 0.5,
            boundaryMargin: EdgeInsets.all(1500),
            builder: (context, _) {
              return Stack(
                children: [
                  ColoredBox(
                    color: Colors.green.shade100,
                    child: SizedBox(width: 300, height: 300),
                  ),
                ],
              );
            },
          ),
          EditorHub(state: _state),
        ],
      ),
    );
  }
}
