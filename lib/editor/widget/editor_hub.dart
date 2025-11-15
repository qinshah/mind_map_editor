import 'package:flutter/material.dart';
import 'package:mind_map_editor/editor/editor.dart';
import 'package:provider/provider.dart';

class EditorHub extends StatelessWidget {
  const EditorHub({super.key, required this.barHeight});

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
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: barHeight,
          child: ColoredBox(
            color: theme.appBarTheme.backgroundColor!,
            child: SingleChildScrollView(
              key: const PageStorageKey('EditorHub'),
              scrollDirection: Axis.horizontal,
              child: FocusScope(
                canRequestFocus: false,
                child: Builder(
                  builder: (context) {
                    return Row(
                      children: [
                        SizedBox(width: 8),
                        // _button(
                        //   '子节点',
                        //   LucideIcons.git_commit_vertical,
                        //   onTap: node == null
                        //       ? null
                        //       : () => mindMap.insertNodeUnder(
                        //           node,
                        //           newNode: Xnode.empty('新节点'),
                        //         ),
                        // ),
                        // _button(
                        //   '同级节点',
                        //   LucideIcons.git_pull_request,
                        //   onTap:
                        //       node != null &&
                        //           mindMap.getParentNode(node) != null
                        //       ? () => mindMap.insertNodeAfter(
                        //           node,
                        //           newNode: Xnode.empty('新节点'),
                        //         )
                        //       : null,
                        // ),
                        // _button(
                        //   node == null || mindMap.getExpanded(node)
                        //       ? '收起'
                        //       : '展开',
                        //   node == null || mindMap.getExpanded(node)
                        //       ? LucideIcons.minimize_2
                        //       : LucideIcons.maximize_2,
                        //   onTap: node == null || node.subNodes.isEmpty
                        //       ? null
                        //       : () => mindMap.toggleExpanded(node),
                        // ),
                        // _button(
                        //   '编辑',
                        //   Icons.edit_outlined,
                        //   onTap: node == null
                        //       ? null
                        //       : () => editor.showEditDialog(node, context),
                        // ),
                        // _button(
                        //   '删除',
                        //   LucideIcons.trash,
                        //   color:  Colors.orange,
                        //   onTap:
                        //       node != null &&
                        //           mindMap.getParentNode(node) != null
                        //       ? () => mindMap.deleteNode(node)
                        //       : null,
                        // ),
                        // VerticalDivider(),
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
                        TextButton(onPressed: editor.import, child: Text('导入')),
                        TextButton(onPressed: editor.export, child: Text('导出')),
                        SizedBox(width: 8),
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

  Widget _button(
    String title,
    IconData icon, {
    VoidCallback? onTap,
    Color? color,
  }) {
    return TextButton(
      style: TextButton.styleFrom(foregroundColor: color),
      onPressed: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 2),
          Icon(icon),
          SizedBox(height: 2),
          Text(title, style: TextStyle(fontSize: 12)),
          SizedBox(height: 2),
        ],
      ),
    );
  }
}
