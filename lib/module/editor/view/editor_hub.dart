import 'package:flutter/material.dart';
import 'package:mind_map_editor/module/editor/editor_notifier.dart';
import 'package:mind_map_editor/module/mind_map/mind_map_cntlr.dart';
import 'package:provider/provider.dart';

class EditorHub extends StatelessWidget {
  const EditorHub(this.mindMapCntlr, {super.key});

  final MindMapCntlr mindMapCntlr;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final notifier = context.watch<EditorNotifier>();
    final state = notifier.state;
    return ListenableBuilder(
      listenable: mindMapCntlr,
      builder: (context, _) {
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
                        onPressed: mindMapCntlr.state.focusedNode == null
                            ? null
                            : () => mindMapCntlr.insertSubNode(
                                mindMapCntlr.state.focusedNode!,
                              ),
                        child: Text('子节点'),
                      ),
                      TextButton(
                        onPressed: mindMapCntlr.insertBrotherNode,
                        child: Text('兄弟节点'),
                      ),
                      IconButton(
                        onPressed: mindMapCntlr.deleteSelected,
                        icon: Icon(Icons.delete_outline),
                      ),
                      IconButton(
                        onPressed: notifier.save,
                        icon: Icon(Icons.save_outlined),
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
