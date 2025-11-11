import 'package:flutter/material.dart';
import 'package:mind_map_editor/mind_map/m_m_theme.dart';
import 'package:mind_map_editor/xmind/xnode_theme.dart';
import 'package:mind_map_editor/xmind/xmind.dart';
import 'package:mind_map_editor/editor/editor.dart';
import 'package:mind_map_editor/editor/widget/editor_hub.dart';
import 'package:mind_map_editor/mind_map/widget/mind_map.dart';
import 'package:mind_map_editor/xmind/widget/xnode_widget.dart';
import 'package:mind_map_editor/common/widget/size_change_notifier.dart';
import 'package:provider/provider.dart';

class EditorWidget extends StatefulWidget {
  const EditorWidget({super.key});

  @override
  State<EditorWidget> createState() => _EditorWidgetState();
}

class _EditorWidgetState extends State<EditorWidget> {
  late final _editor = Editor(getContext: () => context);
  late final _mmCntlr = _editor.mMCnltr;

  final barHeight = 42.0;

  @override
  void initState() {
    super.initState();
    _editor.init();
  }

  @override
  dispose() {
    super.dispose();
    _editor.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _mmCntlr),
        ChangeNotifierProvider.value(value: _editor),
      ],
      child: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              _editor.tCntlr.viewportSize = constraints.biggest;
              final logicSize = constraints.biggest / _editor.tCntlr.minScale;
              final h = (logicSize.width - _editor.state.mapSize.width) / 2;
              final v = (logicSize.height - _editor.state.mapSize.height) / 2;
              return InteractiveViewer.builder(
                onInteractionStart: (_) => _editor.setTransforming(true),
                onInteractionEnd: (_) => _editor.setTransforming(false),
                transformationController: _editor.tCntlr,
                minScale: _editor.tCntlr.minScale,
                maxScale: _editor.tCntlr.maxScale,
                // 让最小倍数时刚好填满视口
                boundaryMargin: EdgeInsets.fromLTRB(
                  h.clamp(0, 1 / 0),
                  v.clamp(barHeight / _editor.tCntlr.minScale, 1 / 0),
                  h.clamp(0, 1 / 0),
                  v.clamp(0, 1 / 0),
                ),
                builder: (context, _) {
                  final editorState = context.watch<Editor>().state;
                  return SizeChangeNotifier(
                    onSizeChange: _editor.updateMapSize,
                    child: MindMap<Xnode>.root(
                      editorState.xmind.root,
                      cntlr: _mmCntlr,
                      nodeWidgetBuilder: (node, path) {
                        return XnodeWidget(
                          node,
                          key: Key(node.id),
                          theme: _buildNodeTheme(path),
                          cntlr: _mmCntlr,
                        );
                      },
                      themeBuilder: _buildTheme,
                      keyBuilder: (Xnode node) {
                        return editorState.transforming
                            ? Key(node.id)
                            : UniqueKey();
                      },
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

  MMTheme _buildTheme(List<int> path) => switch (path.length) {
    // 根节点
    0 => MMTheme(spacingBetweenSubTree: 20, spacingWithSubTree: 50),
    // 根节点的子节点
    1 => MMTheme(spacingBetweenSubTree: 10, spacingWithSubTree: 40),
    // 后续节点
    int() => MMTheme(),
  };

  XnodeTheme _buildNodeTheme(List<int> path) {
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
      0 => XnodeTheme(
        color: color,
        textStyle: TextStyle(
          color: textColor,
          fontSize: 24,
          fontWeight: FontWeight.w800,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      ),
      // 一级分支节点
      1 => XnodeTheme(
        color: color,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        textStyle: TextStyle(
          color: textColor,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      int() => XnodeTheme(
        color: color,
        textStyle: TextStyle(color: textColor),
      ),
    };
  }
}
