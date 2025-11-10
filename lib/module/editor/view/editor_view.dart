import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mind_map_editor/data_model/mind_map_theme.dart';
import 'package:mind_map_editor/data_model/xmind.dart';
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
  final _editor = EditorNotifier();
  late final _mindMap = MindMapCntlr<XNode>(
    onNodeChanged: (_) => _editor.save(),
    newNodeBuilder: () => XNode.newInsert(),
    editDialogBuilder: (XNode value) {},
  );

  @override
  void initState() {
    _editor.loadSavedMindMap();
    HardwareKeyboard.instance.addHandler(_mindMap.onKeyEvent);
    super.initState();
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_mindMap.onKeyEvent);
    super.dispose();
  }

  final barHeight = 42.0;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _mindMap),
        ChangeNotifierProvider.value(value: _editor),
      ],
      child: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final logicSize = constraints.biggest / _editor.state.minScale;
              final h = (logicSize.width - _editor.state.mapSize.width) / 2;
              final v = (logicSize.height - _editor.state.mapSize.height) / 2;
              final rootNode = context.select<EditorNotifier, XNode>((value) {
                return value.state.xmind.root;
              });
              return InteractiveViewer.builder(
                onInteractionUpdate: _editor.updateScale,
                transformationController: _editor.tCntlr,
                minScale: _editor.state.minScale,
                maxScale: _editor.state.maxScale,
                // 让最小倍数时刚好填满视口
                boundaryMargin: EdgeInsets.fromLTRB(
                  h.clamp(0, 1 / 0),
                  v.clamp(barHeight / _editor.state.minScale, 1 / 0),
                  h.clamp(0, 1 / 0),
                  v.clamp(0, 1 / 0),
                ),
                builder: (context, _) {
                  return SizeChangeNotifier(
                    onSizeChange: _editor.updateMapSize,
                    child: MindMap<XNode>.root(
                      rootNode,
                      cntlr: _mindMap,
                      nodeWidgetBuilder: (node, path) {
                        return NodeWidget(
                          node,
                          theme: _buildNodeTheme(path),
                          cntlr: _mindMap,
                        );
                      },
                      themeBuilder: _buildTheme,
                    ),
                  );
                },
              );
            },
          ),
          EditorHub(barHeight: barHeight),
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
