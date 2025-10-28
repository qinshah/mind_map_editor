import 'package:flutter/material.dart';
import 'package:mind_map_editor/editor/editor_notifier.dart';
import 'package:mind_map_editor/editor/view/editor_hub.dart';
import 'package:provider/provider.dart';

class EditorView extends StatelessWidget {
  const EditorView({super.key});

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<EditorNotifier>();
    final state = notifier.state;
    return Scaffold(
      appBar: AppBar(toolbarHeight: 0),
      body: Stack(
        children: [
          InteractiveViewer.builder(
            onInteractionUpdate: notifier.updateScale,
            onInteractionEnd: notifier.endScale,
            transformationController: notifier.tCntlr,
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
          EditorHub(state: state),
        ],
      ),
    );
  }
}
