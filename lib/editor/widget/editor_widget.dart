import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import 'package:mind_map_editor/editor/editor.dart';
import 'package:mind_map_editor/editor/widget/editor_hub.dart';
import 'package:mind_map_editor/xmind/widget/xnode_widget.dart';
import 'package:mind_map_editor/xmind/xmind.dart';
import 'package:mind_map_editor/xmind/xnode_theme.dart';
import 'package:provider/provider.dart';

class EditorWidget extends StatefulWidget {
  const EditorWidget({super.key});

  @override
  State<EditorWidget> createState() => _EditorWidgetState();
}

class _EditorWidgetState extends State<EditorWidget> {
  late final _editor = Editor(getContext: () => context);

  late final _graphCnltr = _editor.graphCnltr;

  final barHeight = 50.0;

  final _builder = BuchheimWalkerConfiguration()
    ..siblingSeparation = (10)
    ..levelSeparation = (10)
    ..subtreeSeparation = (10)
    ..orientation = (BuchheimWalkerConfiguration.ORIENTATION_LEFT_RIGHT);

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
      providers: [ChangeNotifierProvider.value(value: _editor)],
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(top: barHeight),
            child: LayoutBuilder(
              builder: (context, constraints) {
                _editor.tCntlr.viewportSize = constraints.biggest;
                final graph = context.watch<Editor>().graph;
                if (graph == null) {
                  return const Center(child: CircularProgressIndicator());
                }
                return GraphView.builder(
                  toggleAnimationDuration: Durations.short4,
                  controller: _graphCnltr,
                  graph: graph,
                  algorithm: BuchheimWalkerAlgorithm(
                    _builder,
                    TreeEdgeRenderer(_builder),
                  ),
                  builder: (Node node) {
                    return XnodeWidget(
                      node as Xnode,
                      onTap: () => _graphCnltr.toggleNodeExpanded(graph, node),
                      theme: _buildNodeTheme([0,0]),// TODO: 节点主题
                    );
                  },
                );
              },
            ),
          ),
          EditorHub(barHeight: barHeight),
        ],
      ),
    );
  }

  // MMTheme _buildTheme(List<int> path) => switch (path.length) {
  //   // 根节点
  //   0 => MMTheme(spacingBetweenSubTree: 20, spacingWithSubTree: 50),
  //   // 根节点的子节点
  //   1 => MMTheme(spacingBetweenSubTree: 10, spacingWithSubTree: 40),
  //   // 后续节点
  //   int() => MMTheme(),
  // };

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
