import 'package:flutter/material.dart';
import 'package:mind_map_editor/editor/editor_notifier.dart';
import 'package:provider/provider.dart';

class EditorHub extends StatelessWidget {
  const EditorHub({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final notifier = context.watch<EditorNotifier>();
    final state = notifier.state;
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          top: 10,
          left: 10,
          child: TextButton(
            onPressed: notifier.importXmind,
            child: Text('导入xmind'),
          ),
        ),
        if (state.scaleHubTimer.isActive)
          Positioned(
            top: 10,
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
  }
}
