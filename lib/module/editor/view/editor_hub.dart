import 'package:flutter/material.dart';
import 'package:mind_map_editor/module/editor/editor_notifier.dart';
import 'package:mind_map_editor/module/mind_map/mind_map_cntlr.dart';
import 'package:provider/provider.dart';

class EditorHub extends StatelessWidget {
  const EditorHub(this.mindMap, {super.key});

  final MindMapCntlr mindMap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final notifier = context.watch<EditorNotifier>();
    final state = notifier.state;
    return ListenableBuilder(
      listenable: mindMap,
      builder: (context, _) {
        final focusedNode = mindMap.focusedNode();
        return Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: ColoredBox(
                color: theme.appBarTheme.backgroundColor!,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      TextButton(
                        onPressed: focusedNode == null
                            ? null
                            : () => mindMap.insertNodeUnder(focusedNode),
                        child: Text('子节点'),
                      ),
                      TextButton(
                        onPressed:
                            focusedNode != null &&
                                mindMap.getParentNode(focusedNode) != null
                            ? () => mindMap.insertNodeAfter(focusedNode)
                            : null,
                        child: Text('兄弟节点'),
                      ),
                      IconButton(
                        onPressed:
                            focusedNode != null &&
                                mindMap.getParentNode(focusedNode) != null
                            ? () => mindMap.deleteNode(focusedNode)
                            : null,
                        icon: Icon(Icons.delete_outline),
                      ),
                      TextButton(onPressed: notifier.import, child: Text('导入')),
                      TextButton(onPressed: notifier.export, child: Text('导出')),
                    ],
                  ),
                ),
              ),
            ),
            if (state.scaleHubTimer.isActive)
              Positioned(
                top: 50,
                child: Card(
                  color: theme.cardColor.withAlpha(91),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('${state.scale}%'),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
