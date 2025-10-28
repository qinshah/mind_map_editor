import 'package:flutter/material.dart';
import 'package:mind_map_editor/editor/editor_state.dart';

class EditorHub extends StatelessWidget {
  const EditorHub({super.key, required this.state});

  final EditorState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          top: 10,
          left: 10,
          child: TextButton(onPressed: () {}, child: Text('导入xmind')),
        ),
        if (state.scaling)
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
