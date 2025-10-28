import 'package:flutter/material.dart';
import 'package:mind_map_editor/editor/editor_notifier.dart';
import 'package:mind_map_editor/editor/view/editor_hub.dart';
import 'package:mind_map_editor/editor/view/mind_map.dart';
import 'package:mind_map_editor/widget/size_change_notifier.dart';
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
          LayoutBuilder(
            builder: (context, constraints) {
              final logicSize = constraints.biggest / state.minScale;
              final hMargin = (logicSize.width - state.mindMapSize.width) / 2;
              final vMargin = (logicSize.height - state.mindMapSize.height) / 2;
              return InteractiveViewer.builder(
                onInteractionUpdate: notifier.updateScale,
                transformationController: notifier.tCntlr,
                minScale: state.minScale,
                maxScale: state.maxScale,
                // 让最小倍数时刚好填满视口
                boundaryMargin: EdgeInsets.symmetric(
                  horizontal: hMargin,
                  vertical: vMargin,
                ),
                builder: (context, _) {
                  return ColoredBox(
                    color: Colors.white,
                    child: SizeChangeNotifier(
                      onSizeChange: notifier.updateMindMapSize,
                      child: MindMap(
                        state.xmind.root,
                        key: ValueKey(state.xmind.hashCode),
                      ),
                    ),
                  );
                },
              );
            },
          ),
          EditorHub(),
        ],
      ),
    );
  }
}
