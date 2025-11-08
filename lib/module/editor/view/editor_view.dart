import 'package:flutter/material.dart';
import 'package:mind_map_editor/data_model/mind_map_theme.dart';
import 'package:mind_map_editor/module/editor/editor_notifier.dart';
import 'package:mind_map_editor/module/editor/view/editor_hub.dart';
import 'package:mind_map_editor/module/mind_map/mind_map_cntlr.dart';
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
  final _mindMapCntlr = MindMapCntlr();

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
                  horizontal: hMargin > 0 ? hMargin : 0,
                  vertical: vMargin > 0 ? vMargin : 0,
                ),
                builder: (context, _) => SizeChangeNotifier(
                  onSizeChange: notifier.updateMindMapSize,
                  child: FocusScope(
                    child: MindMap.root(
                      state.xmind.root,
                      cntlr: _mindMapCntlr,
                      key: ValueKey(state.xmind.hashCode),
                      nodeBuilder: (node, path) {
                        return NodeWidget(
                          node,
                          theme: _buildNodeTheme(path),
                          cntlr: _mindMapCntlr,
                        );
                      },
                      themeBuilder: _buildTheme,
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

  MindMapTheme _buildTheme(List<int> path) => switch (path.length) {
    // 根节点
    0 => MindMapTheme(spacingBetweenSubTree: 20, spacingWithSubTree: 40),
    // 根节点的子节点
    1 => MindMapTheme(spacingBetweenSubTree: 10, spacingWithSubTree: 30),
    // 后续节点
    int() => MindMapTheme(),
  };

  NodeTheme _buildNodeTheme(List<int> path) {
    final depth = path.length;
    final color =
        // 根节点
        depth == 0
        ? Theme.of(context).primaryColor
        // 控制相同分支色调一致
        : Colors.primaries[path[0] % Colors.primaries.length].withAlpha(
            depth == 1 ? 200 : 144, // 深度1和后续深度
          );
    final textColor = color.computeLuminance() > 0.5
        ? Colors.black
        : Colors.white;
    return switch (depth) {
      // 根节点
      0 => NodeTheme(
        color: color,
        textStyle: TextStyle(
          color: textColor,
          fontSize: 24,
          fontWeight: FontWeight.w800,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      ),
      // 一级分支节点
      1 => NodeTheme(
        color: color,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        textStyle: TextStyle(
          color: textColor,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      int() => NodeTheme(
        color: color,
        textStyle: TextStyle(color: textColor),
      ),
    };
  }
}
