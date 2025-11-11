import 'package:flutter/material.dart';
import 'package:mind_map_editor/xmind/xmind.dart';
import 'package:mind_map_editor/editor/editor.dart';
import 'package:mind_map_editor/mind_map/m_m_cntlr.dart';
import 'package:provider/provider.dart';

class EditorHub extends StatelessWidget {
  const EditorHub({super.key, this.barHeight = 42});

  final double barHeight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final editor = context.watch<Editor>();
    final state = editor.state;
    final tCntlr = editor.tCntlr;
    return Stack(
      alignment: Alignment.center,
      children: [
        if (state.transformingTimer.isActive)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: barHeight,
            child: ColoredBox(
              color: theme.appBarTheme.backgroundColor!,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: FocusScope(
                  canRequestFocus: false,
                  child: Builder(
                    builder: (context) {
                      final mindMap = context.watch<MMCntlr<Xnode>>();
                      final curNode = mindMap.focusedNode();
                      return Row(
                        children: [
                          TextButton(
                            onPressed: curNode == null
                                ? null
                                : () => mindMap.insertNodeUnder(
                                    curNode,
                                    newNode: Xnode.empty('新节点'),
                                  ),
                            child: Text('子节点'),
                          ),
                          TextButton(
                            onPressed:
                                curNode != null &&
                                    mindMap.getParentNode(curNode) != null
                                ? () => mindMap.insertNodeAfter(
                                    curNode,
                                    newNode: Xnode.empty('新节点'),
                                  )
                                : null,
                            child: Text('兄弟节点'),
                          ),
                          IconButton(
                            onPressed: curNode == null
                                ? null
                                : () => editor.showEditDialog(curNode, context),
                            icon: Icon(Icons.edit_outlined),
                          ),
                          IconButton(
                            onPressed:
                                curNode != null &&
                                    mindMap.getParentNode(curNode) != null
                                ? () => mindMap.deleteNode(curNode)
                                : null,
                            icon: Icon(Icons.delete_outline),
                          ),
                          VerticalDivider(),
                          IconButton(
                            onPressed: state.zoom == tCntlr.maxScale * 100
                                ? null
                                : () => tCntlr.zoomIn(scale: 1.5),
                            icon: Icon(Icons.zoom_in),
                          ),
                          IconButton(
                            onPressed: tCntlr.reset,
                            icon: Icon(Icons.refresh),
                          ),
                          IconButton(
                            onPressed: state.zoom == tCntlr.minScale * 100
                                ? null
                                : () => tCntlr.zoomIn(scale: 1 / 1.5),
                            icon: Icon(Icons.zoom_out),
                          ),
                          VerticalDivider(),
                          TextButton(
                            onPressed: editor.import,
                            child: Text('导入'),
                          ),
                          TextButton(
                            onPressed: editor.export,
                            child: Text('导出'),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        if (state.scalingTimer.isActive)
          Positioned(
            top: barHeight,
            child: Card(
              color: theme.cardColor.withAlpha(91),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('${state.zoom}%'),
              ),
            ),
          ),
      ],
    );
  }
}
