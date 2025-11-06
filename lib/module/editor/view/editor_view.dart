import 'package:flutter/material.dart';
import 'package:mind_map_editor/data_model/mind_map_theme.dart';
import 'package:mind_map_editor/data_model/xmind.dart';
import 'package:mind_map_editor/module/editor/editor_notifier.dart';
import 'package:mind_map_editor/module/editor/view/editor_hub.dart';
import 'package:mind_map_editor/module/mind_map/mind_map_notifier.dart';
import 'package:mind_map_editor/module/mind_map/view/mind_map.dart';
import 'package:mind_map_editor/module/mind_map/view/node_widget.dart';
import 'package:mind_map_editor/widget/size_change_notifier.dart';
import 'package:provider/provider.dart';

class EditorView extends StatefulWidget {
  const EditorView({super.key});

  @override
  State<EditorView> createState() => _EditorViewState();
}

class _EditorViewState extends State<EditorView> {
  final _mindMapNotifier = MindMapNotifier();

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
              return ChangeNotifierProvider.value(
                value: _mindMapNotifier,
                child: InteractiveViewer.builder(
                  onInteractionUpdate: notifier.updateScale,
                  transformationController: notifier.tCntlr,
                  minScale: state.minScale,
                  maxScale: state.maxScale,
                  // 让最小倍数时刚好填满视口
                  boundaryMargin: EdgeInsets.symmetric(
                    horizontal: hMargin,
                    vertical: vMargin,
                  ),
                  builder: (context, _) => SizeChangeNotifier(
                    onSizeChange: notifier.updateMindMapSize,
                    child: FocusScope(
                      child: MindMap.root(
                        rootNode: state.xmind.root,
                        key: ValueKey(state.xmind.hashCode),
                        nodeBuilder: (Node node, int depth, int indexOfDepth) {
                          return NodeWidget(node, onTap: () {});
                        },
                        themeBuilder: _buildTheme,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          EditorHub(),
        ],
      ),
    );
  }

  MindMapTheme _buildTheme(int depth) => switch (depth) {
    // 根节点
    0 => MindMapTheme(spacingBetweenSubTree: 20, spacingWithSubTree: 40),
    // 根节点的子节点
    1 => MindMapTheme(spacingBetweenSubTree: 10, spacingWithSubTree: 30),
    // 后续节点
    int() => MindMapTheme(),
  };
}
